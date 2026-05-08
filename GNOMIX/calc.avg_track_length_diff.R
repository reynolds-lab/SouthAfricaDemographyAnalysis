library(broom)
library(svglite)
library(gridExtra)
library(grid)
library(dplyr)
library(tidyr)

tracks <- read.table("~/Dropbox/SA_KhoeSan_Structure/gnomix_asMDS/tracklengths_avg_table_acrosschrs.txt", header=TRUE)
raw_data <- read.table("~/Dropbox/SA_KhoeSan_Structure/gnomix_asMDS/tracklengths_byanc_bysample_acrosschrs.wpops.prob75.txt", header=TRUE)
print(tracks)
head(raw_data)

raw_data %>%
  filter(anc == "NKA") %>%
  group_by(pop) %>%
  summarise(sample_size = n())


cdb_nka <- tracks[4,3]
kro_nka <- tracks[19,3]
org_nka <- tracks[34,3]

diff_cdb_kro <- kro_nka - cdb_nka
diff_cdb_org <- org_nka - cdb_nka
cat("KRO-CDB:", diff_cdb_kro, "\n")
cat("ORG-CDB:", diff_cdb_org, "\n")


library(dplyr)

# Define the populations you want to compare to CDB
comparisons <- c("KRO", "ORG")

# Use lapply to perform the t-test for each comparison
t_test_results <- lapply(comparisons, function(popx) {
  sub_df <- raw_data %>% filter(anc == "NKA", pop %in% c("CDB", popx))
  test <- t.test(len ~ pop, data = sub_df)
  return(test)
})

names(t_test_results) <- comparisons
t_test_results

# Comparison between KRO and ORG for anc == "NKA"
subset_kro_org <- raw_data %>% filter(anc == "NKA", pop %in% c("KRO", "ORG"))
t_test_KRO_ORG <- t.test(len ~ pop, data = subset_kro_org)
print(t_test_KRO_ORG)



# ANOVA
nka_data <- subset(raw_data, anc == "NKA")
anova_result <- aov(len ~ pop, data = nka_data)
summary(anova_result)


# Post hoc Tukey test to check pairwise differences
tukey_result <- TukeyHSD(anova_result)
print(tukey_result)

result_df <- as.data.frame(tukey_result$pop)
result_df$p.adj <- format(result_df$`p adj`, scientific = TRUE)
print(result_df)

