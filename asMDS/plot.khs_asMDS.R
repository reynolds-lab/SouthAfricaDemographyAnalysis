library(ggplot2)
library(dplyr)
library(ggpubr)
library(ggrepel)
library(cowplot)


data <- read.table("Dropbox/SA_KhoeSan_Structure/local_ancestry/maaMDS/files/all_chrs_query_results.40.no_khs_rel.tsv", header = TRUE)
data$SampleID <- sub("_(.*)", "", data$indID)
pop_key <- read.table("Dropbox/SA_KhoeSan_Structure/local_ancestry/maaMDS/files/population_key.txt", header = TRUE)
plot_title <- "all_chrs_query_results.40.no_khs_rel"

merged_data <- merge(data, pop_key, by = "SampleID", all.x = TRUE)
filtered_data <- subset(merged_data, MDS1 < -0.13 | MDS1 > 0.13)
filtered_data


color_mapping_POP <- c("KHM" = "#B0C5A4", "NAM" = "#FFC49F", "ORG" = "#D37676", 
                   "KRO" = "#7d50c2", "CDB" = "#007F73", "NCTB" = "#B30010")
shape_mapping_POP <- c("KHM" = 16, "NAM" = 17, "ORG" = 3, "KRO" = 22, "CDB" = 2, "NCTB" = 21)
color_mapping_LAB <- c("KHS" = "#FFC49F", "QUR_REL" = "#D37676", "KHS_OUT" = "#007F73", 
                   "QUR" = "#7d50c2")
shape_mapping_LAB <- c("KHS" = 17, "QUR_REL" = 3, "KHS_OUT" = 16, "QUR" = 22)


p1 <- ggplot(merged_data, aes(x = MDS1, y = MDS2, color = AllPopulation, shape = AllPopulation)) +
  geom_point(alpha = 0.65, size = 5) +  
  labs(title = paste(plot_title, "by population", sep= ""),
       x = "MDS1",
       y = "MDS2",
       color = "Population",
       shape = "Population") +  
  scale_color_manual(values = color_mapping_POP) +  # Apply manual color mapping
  scale_shape_manual(values = shape_mapping_POP) +  # Apply manual shape mapping
  theme_classic() +
  theme(
    plot.title = element_text(hjust = 0.5,size = 16),
    axis.title.x = element_text(size = 13),
    axis.title.y = element_text(size = 13),
    axis.text.x = element_text(size = 11),
    axis.text.y = element_text(size = 11),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 12), legend.position = "bottom")
  # ) + 
  # geom_text_repel(data = filtered_data, aes(label = indID), 
  #                 size = 3, color = "black", min.segment.length = Inf, 
  #                 seed = 42, box.padding = .2, 
  #                 point.padding = 4,nudge_x = 0.03)

p1



p1d1 <- ggplot(merged_data, aes(x = MDS1, fill = AllPopulation)) +
  geom_density(alpha = 0.3, linewidth = 0.15) +
  ylab("") + xlab("") +
  xlim(c(min(merged_data$MDS1), max(merged_data$MDS1))) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_manual(values = color_mapping_POP) +
  theme_classic() +
  theme(
    legend.position = "none",
    axis.line.x = element_line(size = 0.3),
    axis.line.y = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    plot.margin = unit(c(0, 0, 0, 0), "cm")
  )

p1d2 <- ggplot(merged_data, aes(x = MDS2, fill = AllPopulation)) +
  geom_density(alpha = 0.4, linewidth = 0.2) +
  ylab("") + xlab("") +
  ylim(c(min(merged_data$MDS2), max(merged_data$MDS2))) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_manual(values = color_mapping_POP) +
  theme_classic() +
  theme(
    legend.position = "none",  # Removing legend
    axis.line.x = element_line(size = 0.3),
    axis.line.y = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    plot.margin = unit(c(0, 0, 0, 0), "cm")
  ) + coord_flip()





p2 <- ggplot(merged_data, aes(x = MDS1, y = MDS2, color = label, shape = label)) +
  geom_point(alpha = 0.65, size = 5) +  
  labs(title = paste(plot_title, "by label", sep= ""),
       x = "MDS1",
       y = "",
       color = "Population",
       shape = "Population") +  
  scale_color_manual(values = color_mapping_LAB) +  # Apply manual color mapping
  scale_shape_manual(values = shape_mapping_LAB) +  # Apply manual shape mapping
  theme_classic() +
  theme(
    plot.title = element_text(hjust = 0.5,size = 16),
    axis.title.x = element_text(size = 13),
    axis.title.y = element_text(size = 13),
    axis.text.x = element_text(size = 11),
    axis.text.y = element_text(size = 11),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 12), legend.position = "bottom"
  ) 


p2d1 <- ggplot(merged_data, aes(x = MDS1, fill = label)) +
  geom_density(alpha = 0.3, linewidth = 0.15) +
  ylab("") + xlab("") +
  xlim(c(min(merged_data$MDS1), max(merged_data$MDS1))) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_manual(values = color_mapping_LAB) +
  theme_classic() +
  theme(
    legend.position = "none",
    axis.line.x = element_line(size = 0.3),
    axis.line.y = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    plot.margin = unit(c(0, 0, 0, 0), "cm")
  )

p2d2 <- ggplot(merged_data, aes(x = MDS2, fill = label)) +
  geom_density(alpha = 0.4, linewidth = 0.2) +
  ylab("") + xlab("") +
  ylim(c(min(merged_data$MDS2), max(merged_data$MDS2))) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_manual(values = color_mapping_LAB) +
  theme_classic() +
  theme(
    legend.position = "none",  # Removing legend
    axis.line.x = element_line(size = 0.3),
    axis.line.y = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    plot.margin = unit(c(0, 0, 0, 0), "cm")
  ) + coord_flip()





plot1 <- ggarrange(ggarrange(p1d1, NULL, p1, p1d2,
                             ncol = 2, nrow = 2,  align = "hv",
                             widths = c(2, 0.5), heights = c(0.6, 2), common.legend = T, legend = "none"),
                    cowplot::get_plot_component(p1, "guide-box", return_all = TRUE), nrow = 2, heights = c(4, 0.9))

plot2 <- ggarrange(ggarrange(p2d1, NULL, p2, p2d2,
                                    ncol = 2, nrow = 2,  align = "hv",
                                    widths = c(2, 0.5), heights = c(0.6, 2), common.legend = T, legend = "none"),
                          cowplot::get_plot_component(p2, "guide-box", return_all = TRUE), nrow = 2, heights = c(4, 0.9))

figure <- plot_grid(plot1, plot2, ncol = 2, rel_widths = c(1.5, 1.5))

ggsave(filename = paste(data_file, ".pdf", sep = ""), plot = figure, height = 10, width = 15)
