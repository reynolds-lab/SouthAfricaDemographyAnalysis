library(dplyr)
library(reshape2)
library(pheatmap)

# Load data
ZA_IBD_table <- read.table("/data/reynoldsa_shared/projects/SAfrica_popgen/GERMLINE_qc_from_augrabies/feb25_norel.edgelist")

# Assign column names
colnames(ZA_IBD_table) <- c("Pop1","Sample1","Pop2", "Sample2", "sum_length")

# Convert sum_length to numeric
ZA_IBD_table$sum_length <- as.numeric(as.character(ZA_IBD_table$sum_length))

# Convert population columns to character
ZA_IBD_table$Pop1 <- as.character(ZA_IBD_table$Pop1)
ZA_IBD_table$Pop2 <- as.character(ZA_IBD_table$Pop2)

# Clean population names
ZA_IBD_table$Pop1 <- gsub(pattern ='[0-9]' ,replacement = "", ZA_IBD_table$Pop1)
ZA_IBD_table$Pop2 <- gsub(pattern ='[0-9]' ,replacement = "", ZA_IBD_table$Pop2)
ZA_IBD_table$Pop1 <- sub("_.*", "", ZA_IBD_table$Pop1)
ZA_IBD_table$Pop2 <- sub("_.*", "", ZA_IBD_table$Pop2)

# Filter for significant IBD relationships
ZA_IBD_table <- ZA_IBD_table %>% filter(sum_length >= 13)

# Check if data exists after filtering
if (nrow(ZA_IBD_table) == 0) {
  stop("Error: No data left after filtering. Check input file or threshold.")
}

# Ensure consistent ordering of population pairs
ZA_IBD_table <- ZA_IBD_table %>%
  rowwise() %>%
  mutate(Pop1_final = min(Pop1, Pop2),
         Pop2_final = max(Pop1, Pop2)) %>%
  ungroup()

# Summarize mean IBD for each unique population pair
ibd_summary <- ZA_IBD_table %>%
  group_by(Pop1_final, Pop2_final) %>%
  summarise(avg_length = mean(sum_length), .groups = "drop")

# Reshape to wide format
ibd_matrix <- dcast(ibd_summary, Pop1_final ~ Pop2_final, value.var = "avg_length", fill = NA)

# Ensure matrix has values
if (nrow(ibd_matrix) == 0) {
  stop("Error: dcast() produced an empty matrix. Check group_by or summarise steps.")
}

# Set row names and remove the first column
rownames(ibd_matrix) <- ibd_matrix$Pop1_final
ibd_matrix <- ibd_matrix[, -1]

# Mirror the lower triangle for symmetry
ibd_matrix[lower.tri(ibd_matrix)] <- NA

# Define color palette
red_blue_palette <- colorRampPalette(c("white", "#006C75"))(500)

# Save heatmap
pdf("/data/reynoldsa_shared/projects/SAfrica_popgen/GERMLINE_qc_from_augrabies/31ibd_heatmap_unique_pairs.pdf", width = 8, height = 6)
pheatmap(ibd_matrix,
         display_numbers = TRUE,
         treeheight_row = 0,
         treeheight_col = 0,
         cluster_rows = FALSE,
         cluster_cols = FALSE,
         color = red_blue_palette,
         na_col = "black",
         border_color = "black",
         number_color = "black",
         main = "Mean Shared IBD Between Populations"
)
dev.off()
