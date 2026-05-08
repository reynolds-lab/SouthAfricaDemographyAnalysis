library(effects)
library(ggplot2)
library(patchwork)
library(cowplot) 
library(tidyverse)


setwd("/Users/danaal-hindi/Dropbox/SA_KhoeSan_Structure")

gnomix <- read.table("local_ancestry/merge_part4/gnomix_global_ancestry_results.txt", header=T)
admixture <- read.table("admixture/KHS_averaged_admixture_data.csv", header=T, sep=",")
head(gnomix)
colnames(gnomix) <- c("sample_id","EASg","EURg","KHSg","NKAg","SASg")
gnomix <- gnomix %>%
  separate(sample_id, into = c("Pop", "sample_id"), sep = "_")

head(gnomix)
head(admixture)

merged_data <- merge(gnomix, admixture, by.x = "sample_id", by.y = "Sample")
head(merged_data)
nrow(merged_data)





NKAcorrelation_matrix <- cor(merged_data[, c("NKA", "NKAg")])
NKAcorrelation_coefficient <- NKAcorrelation_matrix[1, 2]
NKArsquared <- NKAcorrelation_coefficient^2
NKA <- ggplot(merged_data, aes(x = NKAg, y = NKA)) +
  geom_point(shape = 16, size = 3, alpha = 0.4) +
  geom_abline(intercept = 0, slope = 1, color = "blue", linewidth = .5) +
  geom_smooth(method = "lm", formula = y ~ x, color = "red", se = FALSE, linewidth = .74) +
  xlim(0, 1) +
  ylim(0, 1) +
  labs(title = "NKA",
       x = "",
       y = "Admixture") +
  annotate("text", x = 0.86, y = 0.01, 
           label = paste("R^2 =", round(NKArsquared, 3)),
           color = "black", size = 4) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))


EURcorrelation_matrix <- cor(merged_data[, c("EUR", "EURg")])
EURcorrelation_coefficient <- EURcorrelation_matrix[1, 2]
EURrsquared <- EURcorrelation_coefficient^2
EUR <- ggplot(merged_data, aes(x = EURg, y = EUR)) +
  geom_point(shape = 16, size = 3, alpha = 0.4) +
  geom_abline(intercept = 0, slope = 1, color = "blue", linewidth = .5) +
  geom_smooth(method = "lm", formula = y ~ x, color = "red", se = FALSE, linewidth = .74) +
  xlim(0, 1) +
  ylim(0, 1) +
  labs(title = "EUR",
       x = "",
       y = "") +
  annotate("text", x = 0.86, y = 0.01, 
           label = paste("R^2 =", round(EURrsquared, 3)),
           color = "black", size = 4) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))


KHMcorrelation_matrix <- cor(merged_data[, c("KHM", "KHSg")])
KHMcorrelation_coefficient <- KHMcorrelation_matrix[1, 2]
KHMrsquared <- KHMcorrelation_coefficient^2
KHM <- ggplot(merged_data, aes(x = KHSg, y = KHM)) +
  geom_point(shape = 16, size = 3, alpha = 0.4) +
  geom_abline(intercept = 0, slope = 1, color = "blue", linewidth = .5) +
  geom_smooth(method = "lm", formula = y ~ x, color = "red", se = FALSE, linewidth = .74) +
  xlim(0, 1) +
  ylim(0, 1) +
  labs(title = "KHS",
       x = "GNOMIX",
       y = "") +
  annotate("text", x = 0.86, y = 0.01, 
           label = paste("R^2 =", round(KHMrsquared, 3)),
           color = "black", size = 4) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))



SAScorrelation_matrix <- cor(merged_data[, c("SAS", "SASg")])
SAScorrelation_coefficient <- SAScorrelation_matrix[1, 2]
SASrsquared <- SAScorrelation_coefficient^2
SAS <- ggplot(merged_data, aes(x = SASg, y = SAS)) +
  geom_point(shape = 16, size = 3, alpha = 0.5) +
  geom_abline(intercept = 0, slope = 1, color = "blue") +
  geom_smooth(method = "lm", formula = y ~ x, color = "red", se = FALSE) +
  xlim(0, 0.60) +
  ylim(0, 0.60) +
  labs(title = "SAS",
       x = "GNOMIX",
       y = "Admixture") +
  annotate("text", x = 0.51, y = 0.01, 
           label = paste("R^2 =", round(SASrsquared, 3)),
           color = "black", size = 4) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))


EAScorrelation_matrix <- cor(merged_data[, c("EAS", "EASg")])
EAScorrelation_coefficient <- EAScorrelation_matrix[1, 2]
EASrsquared <- EAScorrelation_coefficient^2
EAS <- ggplot(merged_data, aes(x = EASg, y = EAS)) +
  geom_point(shape = 16, size = 3, alpha = 0.5) +
  geom_abline(intercept = 0, slope = 1, color = "blue") +
  geom_smooth(method = "lm", formula = y ~ x, color = "red", se = FALSE) +
  xlim(0, 0.20) +
  ylim(0, 0.20) +
  labs(title = "EAS",
       x = "GNOMIX",
       y = "") +
  annotate("text", x = 0.17, y = 0.01, 
           label = paste("R^2 =", round(EASrsquared, 3)),
           color = "black", size = 4) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))




pdf("/Users/danaal-hindi/Dropbox/SA_KhoeSan_Structure/figures/gnomix_admixture_correlation_plots.output5.pdf", width = 14, height = 9)
grid <- plot_grid(
  NKA,
  EUR,
  KHM,
  SAS,
  EAS,
  nrow = 2,
  rel_widths = c(3, 3)
)
grid


dev.off()

