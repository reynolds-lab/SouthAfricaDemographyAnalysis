library(svglite)
library(gridExtra)
library(grid)
library(dplyr)
library(tidyr)

# nka : ~/Dropbox/SA_KhoeSan_Structure/gnomix_asMDS/asMDS_nka/all_sa_query.nka_anc.10min.w01.no_bsan2
# nka : ~/Dropbox/SA_KhoeSan_Structure/gnomix_asMDS/asMDS_khs/all_query_proj.10min.prob75
# eur : ~/Dropbox/SA_KhoeSan_Structure/gnomix_asMDS/asMDS_eur/all_eur.20min.w01
# sas : ~/Dropbox/SA_KhoeSan_Structure/gnomix_asMDS/asMDS_sas/all_sas.10min.w01.proj_all_outrm.prob95
# eas : ~/Dropbox/SA_KhoeSan_Structure/gnomix_asMDS/asMDS_eas/EASanc.10min.prob95

file <- "~/Dropbox/SA_KhoeSan_Structure/gnomix_asMDS/asMDS_eas/EASanc.10min.prob95"
path_to_save <- "~/Dropbox/SA_KhoeSan_Structure/gnomix_asMDS/asMDS_eas/"

mds_data <- read.table(paste(file, ".tsv", sep=""), header = TRUE)
pop_key  <- read.table("~/Dropbox/SA_KhoeSan_Structure/samples/population_key.4.txt", header = TRUE)

mds_data <- mds_data %>%
  mutate(pop = sub("_.*", "", label)) %>%
  mutate(sampleID = sub("^(([^_]+_[^_]+)).*$", "\\1", indID))

mds_data <- mds_data %>%
  left_join(pop_key %>% select(indID, island2), by = c("sampleID" = "indID"))
mds_data <- mds_data %>% filter(island2 != "BSAN_UNK")

# Change the following depedning on which ancestry you are working with
mds_data <- mds_data %>%
  mutate(pop = ifelse(pop == "EAS" & !is.na(island2) & island2 != "BSAN", island2, pop))
mds_data <- mds_data %>%
  mutate(pop = ifelse(pop == "QUR" & !is.na(island2) & island2 != "BSAN", island2, pop))
print(unique(mds_data$pop))


centroids <- mds_data %>%
  group_by(pop) %>%
  summarise(
    centroid_MDS1 = mean(MDS1, na.rm = TRUE),
    centroid_MDS2 = mean(MDS2, na.rm = TRUE)
  )

# Convert the centroids to a matrix (rows: populations, columns: MDS1 and MDS2)
centroid_matrix <- as.matrix(centroids[, c("centroid_MDS1", "centroid_MDS2")])
rownames(centroid_matrix) <- centroids$pop

# Compute the pairwise Euclidean distance matrix in 2D
distance_matrix <- as.matrix(dist(centroid_matrix, method = "euclidean"))

# Format the distances to three decimals (with trailing zeros)
distance_matrix_formatted <- apply(distance_matrix, c(1,2), function(x) sprintf("%.3f", x))
print(distance_matrix_formatted)

# remove "KHM","NAM" for EAS
desired_order <- c("KHM","NAM","CDB", "KRO", "ORG", "NCTB", "Sulawesi", "Java", "Flores", "Sumatra")
new_order <- c(desired_order, setdiff(rownames(distance_matrix_formatted), desired_order))
distance_matrix_formatted <- distance_matrix_formatted[new_order, new_order]
print(distance_matrix_formatted)


# Save Table
mytheme <- ttheme_default(
  core = list(
    bg_params = list(fill = "white", col = "black"),
    fg_params = list(fontface = "plain", fontsize = 10, col = "black")
  ),
  colhead = list(
    bg_params = list(fill = "white", col = "black"),
    fg_params = list(fontface = "plain", fontsize = 10, col = "black")
  ),
  rowhead = list(
    bg_params = list(fill = "white", col = "black"),
    fg_params = list(fontface = "plain", fontsize = 10, col = "black")
  )
)

distance_table <- tableGrob(distance_matrix_formatted, theme = mytheme)

pdf(paste(path_to_save, "distance_matrix_table.pdf", sep=""), width = 12, height = 8)
grid.draw(distance_table)
dev.off()

svglite::svglite(paste(path_to_save, "distance_matrix_table.svg", sep=""), width = 12, height = 8)
grid.draw(distance_table)
dev.off()
 
write.table(distance_matrix, file = paste(path_to_save, "distance_matrix_table.tsv", sep=""), sep = "\t", 
            row.names = TRUE, col.names = TRUE, quote = FALSE)


## South Asian Ancestry Count
observed_counts <- c(CDB = 234, ORG = 24, KRO = 93, NCTB = 84)
chisq_result <- chisq.test(observed_counts)
print(chisq_result)

posthoc_results <- chisq.posthoc.test(observed_counts, p.adjust.method = "bonferroni")
posthoc_results



# 
# 
# # significant? 
# 
# pairwise_perm <- function(pop1, pop2, n_perm = 10000, data = mds_data) {
#   group1 <- data$MDS1[data$island2 == pop1]
#   group2 <- data$MDS1[data$island2 == pop2]
#   
#   obs_diff <- abs(mean(group1, na.rm = TRUE) - mean(group2, na.rm = TRUE))
#   
#   n1 <- length(group1)
#   n2 <- length(group2)
#   
#   combined <- c(group1, group2)
#   
#   perm_diffs <- replicate(n_perm, {
#     permuted <- sample(combined)
#     abs(mean(permuted[1:n1]) - mean(permuted[(n1 + 1):(n1 + n2)]))
#   })
#   
#   p_value <- mean(perm_diffs >= obs_diff)
#   
#   return(list(observed_difference = obs_diff, p_value = p_value, perm_diffs = perm_diffs))
# }
# 
# pairwise_boot <- function(pop1, pop2, n_boot = 10000, data = mds_data) {
#   group1 <- data$MDS1[data$island2 == pop1]
#   group2 <- data$MDS1[data$island2 == pop2]
#   
#   n1 <- length(group1)
#   n2 <- length(group2)
#   
#   boot_diffs <- replicate(n_boot, {
#     boot_group1 <- sample(group1, n1, replace = TRUE)
#     boot_group2 <- sample(group2, n2, replace = TRUE)
#     abs(mean(boot_group1) - mean(boot_group2))
#   })
#   
#   ci <- quantile(boot_diffs, probs = c(0.025, 0.975))
#   
#   return(list(bootstrap_differences = boot_diffs, CI = ci))
# }
# 
# 
# 
# 
# set.seed(123)  # for reproducibility
# perm_result <- pairwise_perm("KHM", "KRO", n_perm = 10000, data = mds_data)
# cat("Permutation Test (KHM vs. KRO):\n")
# cat("Observed difference:", perm_result$observed_difference, "\n")
# cat("P-value:", perm_result$p_value, "\n\n")
