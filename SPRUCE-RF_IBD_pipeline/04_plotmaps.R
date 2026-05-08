############################################################
# PLOTMAPS (MAPS POST-PROCESSING)
# Visualization of MAPS output
############################################################

library(plotmaps)
library(randomForestSRC)

############################################################
# Step 1: Install / load plotmaps (if needed)
############################################################

# install.packages("devtools")
# devtools::install_local("/Users/wendyedington/Desktop/Reynolds Lab/plotmaps-master/")

library(plotmaps)

############################################################
# Step 2: Plot MAPS results
############################################################

plot_maps(
  add.pts = TRUE,
  add.graph = TRUE,
  add.countries = FALSE,
  mcmcpath = "/share/hennlab/projects/SPRUCE_sa/MAPS/runs/dec2024_2_6-output/",
  longlat = FALSE,
  outpath = "/share/hennlab/projects/SPRUCE_sa/MAPS/runs/dec2024_2_6-plotmaps/",
  width = 10,
  height = 6
)

############################################################
# Step 3: Inspect MAPS internal structure (optional)
############################################################

mcmcpath <- "/share/hennlab/projects/SPRUCE_sa/MAPS/runs/dec2024_2_6-output"

oDemes <- scan(paste0(mcmcpath, "/rdistoDemes.txt"), quiet = TRUE)
oDemes <- matrix(oDemes, ncol = 3, byrow = TRUE)

coord <- oDemes[,1:2]

if (!FALSE) {
  long <- coord[2]
  lat <- coord[1]
} else {
  long <- coord[1]
  lat <- coord[2]
}

############################################################
# Step 4: Optional demes metadata check
############################################################

demes <- read.table(
  "/share/hennlab/projects/SPRUCE_sa/MAPS/runs/dec2024_2_6-output/demes.txt"
)

colnames(demes)[2] <- "Lat"
