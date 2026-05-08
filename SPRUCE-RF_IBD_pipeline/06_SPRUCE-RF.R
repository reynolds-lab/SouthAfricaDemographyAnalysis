############################################################
# SPRUCE-RF / MAPS
# Random Forest analysis of environmental predictors of migration rates
############################################################

library(devtools)
library(randomForestSRC)
library(plotmaps)

############################################################
# STEP 1: Plot MAPS output (visual check)
############################################################

plot_maps(
  add.pts = TRUE,
  add.graph = TRUE,
  add.countries = FALSE,
  mcmcpath = "/share/hennlab/projects/SPRUCE_sa/MAPS/runs/jan2025_2-6-output/",
  longlat = FALSE,
  outpath = "/share/hennlab/projects/SPRUCE_sa/MAPS/runs/jan2025_2-6-plotmaps/",
  width = 10,
  height = 6
)

############################################################
# STEP 2: Load environmental data
############################################################

env_path <- "/share/hennlab/projects/SPRUCE_sa/EnvironmentalData/ExtractedValues_35/files_w_NA"

Env.Table <- data.frame(
  Altitude = read.table(file.path(env_path, "modified_wnamibia_altitude_1KMmedian.txt")),
  Slope    = read.table(file.path(env_path, "modified_wnamibia_slope_1KMmedian_MERIT.txt")),
  Lakes    = read.table(file.path(env_path, "modified_wnamibia_za_lakes.txt")),
  Rivers   = read.table(file.path(env_path, "modified_wnamibia_za_rivers.txt")),
  MeanTemp = read.table(file.path(env_path, "modified_wnamibia_bio1_mean.txt")),
  MaxTemp  = read.table(file.path(env_path, "modified_wnamibia_bio5_mean.txt")),
  MinTemp  = read.table(file.path(env_path, "modified_wnamibia_bio6_mean.txt")),
  MeanPrec = read.table(file.path(env_path, "modified_wnamibia_bio12_mean.txt")),
  PrecWet  = read.table(file.path(env_path, "modified_wnamibia_bio13_mean.txt")),
  PrecDry  = read.table(file.path(env_path, "modified_wnamibia_bio14_mean.txt"))
)

names(Env.Table) <- c(
  "Altitude","Slope","Lakes","Rivers",
  "MeanTemp","MaxTemp","MinTemp",
  "MeanPrec","PrecWet","PrecDry"
)

############################################################
# STEP 3: Load MAPS migration rates (2–6 cM)
############################################################

mRates <- read.table(
  "/share/hennlab/projects/SPRUCE_sa/MAPS/runs/jan2025_2-6-output/mRates.txt",
  header = FALSE
)

mRates_2_6 <- colMeans(log(10^(mRates)))

############################################################
# STEP 4: Combine datasets
############################################################

Full.Table <- cbind(Env.Table, mRates_2_6)
Full.Table <- Full.Table[complete.cases(Full.Table), ]

# ensure numeric
Full.Table[] <- lapply(Full.Table, function(x) as.numeric(as.character(x)))

############################################################
# STEP 5: Random Forest model (tuned)
############################################################

rf_formula <- mRates_2_6 ~ Altitude + Slope + Lakes + Rivers +
  MeanTemp + MaxTemp + MinTemp +
  MeanPrec + PrecWet + PrecDry

rf_tune <- tune(
  rf_formula,
  data = Full.Table,
  importance = TRUE,
  na.action = "na.omit"
)

rf_model <- rfsrc(
  rf_formula,
  data = Full.Table,
  importance = TRUE,
  na.action = "na.omit",
  mtry = rf_tune$optimal$mtry,
  nodesize = rf_tune$optimal$nodesize
)

############################################################
# STEP 6: Model evaluation
############################################################

R <- cor(rf_model$predicted.oob, Full.Table$mRates_2_6)
RMSE <- sqrt(mean((rf_model$predicted.oob - Full.Table$mRates_2_6)^2))

print(rf_model)
print(paste("R =", R))
print(paste("RMSE =", RMSE))

############################################################
# STEP 7: Variable importance plot
############################################################

pdf("mRates_2-6_varImp.pdf", 10, 7)
plot(rf_model, m.target = NULL, sorted = TRUE, plots.one.page = TRUE)
dev.off()

############################################################
# STEP 8: Predicted vs observed plot
############################################################

pdf("mRates_2-6_scatter.pdf", 5, 5)
plot(
  rf_model$predicted.oob,
  Full.Table$mRates_2_6,
  xlab = "Predicted migration",
  ylab = "Observed migration (MAPS)"
)
legend(
  "bottomright",
  legend = paste0("Pearson R = ", round(R, 3)),
  cex = 0.8
)
dev.off()

############################################################
# STEP 9: Optional averaged MAPS runs (if needed later)
############################################################

# (kept out intentionally for clarity — can be added as extension block)
