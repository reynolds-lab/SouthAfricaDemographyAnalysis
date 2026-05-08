############################################################
# GERMLINE IBD NETWORK VISUALISATION (SA POPULATIONS)
# Input: GERMLINE/HAP-IBD processed edgelist
# Output: spatial network plots + legends
############################################################

library(dplyr)
library(ggplot2)
library(igraph)
library(scales)
library(reshape2)
library(maps)

############################################################
# 1. LOAD IBD DATA
############################################################

ZA_IBD_table <- read.table(
  "/data/reynoldsa_shared/projects/SAfrica_popgen/GERMLINE_qc_from_augrabies/feb25_norel.edgelist"
)

colnames(ZA_IBD_table) <- c("Pop1", "Sample1", "Pop2", "Sample2", "sum_length")

ZA_IBD_table$sum_length <- as.numeric(as.character(ZA_IBD_table$sum_length))

ZA_IBD_table$Pop1 <- as.character(ZA_IBD_table$Pop1)
ZA_IBD_table$Pop2 <- as.character(ZA_IBD_table$Pop2)

############################################################
# 2. CLEAN POPULATION LABELS
############################################################

ZA_IBD_table$Pop1 <- gsub("[0-9]", "", ZA_IBD_table$Pop1)
ZA_IBD_table$Pop2 <- gsub("[0-9]", "", ZA_IBD_table$Pop2)

ZA_IBD_table$Pop1 <- sub("_.*", "", ZA_IBD_table$Pop1)
ZA_IBD_table$Pop2 <- sub("_.*", "", ZA_IBD_table$Pop2)

############################################################
# 3. FILTER IBD THRESHOLD
############################################################

ZA_IBD_table <- ZA_IBD_table %>%
  filter(sum_length >= 13)

############################################################
# 4. POPULATION METADATA
############################################################

pop_coordinates <- data.frame(
  population = c("CDB", "KRO", "KHM", "NAM", "NCTB", "ORG"),
  Latitude = c(-31.3, -30.5, -27, -28.4, -28.4, -29),
  Longitude = c(19.2, 20.5, 20.9, 17, 21.2, 19)
)

pop_sizes <- data.frame(
  population = c("CDB", "KRO", "KHM", "NAM", "NCTB", "ORG"),
  size = c(120, 137, 68, 70, 163, 81)
)

############################################################
# 5. STANDARDISE PAIR ORDERING
############################################################

ZA_IBD_table <- ZA_IBD_table %>%
  rowwise() %>%
  mutate(
    Pop1_final = min(Pop1, Pop2),
    Pop2_final = max(Pop1, Pop2)
  ) %>%
  ungroup()

############################################################
# 6. WITHIN- AND BETWEEN-POPULATION IBD
############################################################

within_pop_ibd <- ZA_IBD_table %>%
  filter(Pop1 == Pop2) %>%
  group_by(Pop1) %>%
  summarise(avg_within_ibd = mean(sum_length), .groups = "drop") %>%
  rename(population = Pop1)

between_pop_ibd <- ZA_IBD_table %>%
  filter(Pop1 != Pop2) %>%
  group_by(Pop1, Pop2) %>%
  summarise(avg_between_ibd = mean(sum_length), .groups = "drop")

############################################################
# 7. NODE DATA
############################################################

node_data <- merge(pop_coordinates, within_pop_ibd, by = "population", all.x = TRUE)
node_data <- merge(node_data, pop_sizes, by = "population", all.x = TRUE)

# fill missing values safely
node_data$avg_within_ibd[is.na(node_data$avg_within_ibd)] <- 
  min(node_data$avg_within_ibd, na.rm = TRUE) * 0.8

############################################################
# 8. EDGE DATA
############################################################

edge_data <- data.frame(
  from = between_pop_ibd$Pop1,
  to = between_pop_ibd$Pop2,
  weight = between_pop_ibd$avg_between_ibd
)

############################################################
# 9. GRAPH OBJECT
############################################################

g <- graph_from_data_frame(edge_data, directed = FALSE, vertices = node_data)

############################################################
# 10. COLOURS
############################################################

new_palette <- colorRampPalette(
  c("#ecfefe", "#c4e3e4", "#9cc9ca", "#74afb2", "#49959a", "#027c83")
)(100)

############################################################
# 11. TRANSFORMATIONS
############################################################

node_data$log_within_ibd <- log1p(node_data$avg_within_ibd)
edge_data$log_weight <- log1p(edge_data$weight)

quantile_breaks <- quantile(
  c(node_data$avg_within_ibd, edge_data$weight),
  probs = seq(0, 1, length.out = 6),
  na.rm = TRUE
)

############################################################
# 12. EDGE COORDINATES
############################################################

edge_data_for_plot <- edge_data %>%
  left_join(node_data %>% rename(from = population) %>% select(from, Longitude, Latitude), by = "from") %>%
  rename(x = Longitude, y = Latitude) %>%
  left_join(node_data %>% rename(to = population) %>% select(to, Longitude, Latitude), by = "to") %>%
  rename(xend = Longitude, yend = Latitude)

############################################################
# 13. BASE MAP
############################################################

sa_map <- ggplot() +
  geom_polygon(
    data = map_data("world"),
    aes(x = long, y = lat, group = group),
    color = "#9c9c9c",
    fill = "#f3f3f3"
  ) +
  geom_polygon(
    data = map_data("world")[map_data("world")$region == "South Africa", ],
    aes(x = long, y = lat, group = group),
    color = "black",
    fill = "lightgrey"
  ) +
  coord_fixed(1.2, xlim = c(15, 23), ylim = c(-34.5, -24.9))

############################################################
# 14. NETWORK PLOT (LOG SCALE)
############################################################

sa_map_log <- sa_map +
  geom_segment(
    data = edge_data_for_plot,
    aes(x = x, y = y, xend = xend, yend = yend, color = log_weight),
    linewidth = 1.2
  ) +
  geom_point(
    data = node_data,
    aes(x = Longitude, y = Latitude, size = size, fill = log_within_ibd),
    shape = 21, color = "black", stroke = 0.5
  ) +
  geom_text(
    data = node_data,
    aes(x = Longitude, y = Latitude, label = population),
    nudge_y = 0.3,
    size = 4,
    fontface = "bold"
  ) +
  scale_fill_gradientn(
    colors = new_palette,
    name = "Within-pop IBD (log)",
    labels = function(x) round(expm1(x), 1)
  ) +
  scale_color_gradientn(
    colors = new_palette,
    name = "Between-pop IBD (log)",
    labels = function(x) round(expm1(x), 1)
  ) +
  scale_size_continuous(name = "Sample size", range = c(6, 16)) +
  theme_minimal()

############################################################
# 15. NETWORK PLOT (QUANTILE SCALE)
############################################################

sa_map_quantile <- sa_map +
  geom_segment(
    data = edge_data_for_plot,
    aes(x = x, y = y, xend = xend, yend = yend, color = weight),
    linewidth = 1.2
  ) +
  geom_point(
    data = node_data,
    aes(x = Longitude, y = Latitude, size = size, fill = avg_within_ibd),
    shape = 21, color = "black", stroke = 0.5
  ) +
  geom_text(
    data = node_data,
    aes(x = Longitude, y = Latitude, label = population),
    nudge_y = 0.3,
    size = 4,
    fontface = "bold"
  ) +
  scale_fill_gradientn(
    colors = new_palette,
    name = "Within-pop IBD",
    breaks = quantile_breaks
  ) +
  scale_color_gradientn(
    colors = new_palette,
    name = "Between-pop IBD",
    breaks = quantile_breaks
  ) +
  scale_size_continuous(name = "Sample size", range = c(6, 16)) +
  theme_minimal()

############################################################
# 16. SAVE OUTPUTS
############################################################

ggsave("SA_IBD_network_log.pdf", sa_map_log, width = 12, height = 10)
ggsave("SA_IBD_network_quantile.pdf", sa_map_quantile, width = 12, height = 10)
