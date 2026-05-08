library(dplyr)

setwd("/Users/danaal-hindi/Dropbox/SA_KhoeSan_Structure")

msp_all <- NULL
msp_all <- read.table(paste0("local_ancestry/merge_part3/all_chrs_query_results.msp"),
                      , header=T,comment.char = "",skip=1, sep="\t")

colnames(msp_all) <- c("Chr", "Start", "End", "sgpos","egpos","nsnps",
                       gsub("\\.0","_A", gsub("\\.1","_B",colnames(msp_all[-c(1:6)]))))

msp_all$Start <- as.integer(msp_all$Start)
msp_all$End <- as.integer(msp_all$End)
nrow(msp_all)

#sample randomly
n = round(.05*nrow(msp_all))
print(n)
msp_all <- msp_all[sample(nrow(msp_all), n),]
nrow(msp_all)
samples <- colnames(msp_all[-c(1:6)])

### 2. Calculate track length
lengths = as.data.frame(matrix(0, nrow = 0, ncol = 3))
colnames(lengths) <- c("sample", "len","anc")
lengths$sample <- as.character(lengths$sample)
lengths$len <- as.integer(lengths$len)
lengths$anc <- as.integer(lengths$anc)
for (sample in samples){
  print(sample)
  ## Keep columns in msp
  if(length(which(colnames(msp_all)==sample))>0){ #check if sample exists
    col1 <- which(colnames(msp_all)==sample)
    msp_ind <- msp_all[,c(1:3, col1)]
    #Subpopulation order/codes: EUR=0  EAS=1  SAS=2   NKA=3   KHS=4
    ancs=c("EUR","EAS","SAS","NKA","KHS")
    for(chr in 1:22){
      print(chr)
      msp_ind_chr <- msp_ind[which(msp_ind$Chr==chr),]
      a <- 0
      for (anc in ancs){
        if(length(which(msp_ind_chr[,4]==a))>0){
          anc_seg_all <- which(msp_ind_chr[,4]==a) #get where are the 0 windows
          anc_chunks <- split(anc_seg_all, cumsum(c(1, diff(anc_seg_all) != 1))) #merge consecutive 0 windows into chunks
          for (i in 1:length(anc_chunks)){
            anc_chunks_df <- as.data.frame(anc_chunks[i])
            pos1 <- anc_chunks_df[1,] #first position
            pos2 <- anc_chunks_df[nrow(anc_chunks_df),] #last position
            len <- msp_ind_chr[pos2,3]-msp_ind_chr[pos1,2]
            lengths <- rbind(lengths, cbind(sample, len, anc))
          }
        }
        a <- a+1
      }
    }
  }
}
head(lengths)
write.table(lengths, "local_ancestry/merge_part3/Track_Lengths_perAncestry_perSample_allchrs_filtered.output4.txt", row.names = F, quote = F)

lengths <- read.table(file="local_ancestry/merge_part3/Track_Lengths_perAncestry_perSample_allchrs_filtered.output4.txt",
                      comment.char = "",skip=1, sep="", header=F, col.names=c("sample", "len", "anc"))
head(lengths)
print(mean(lengths$len))
print(median(lengths$len))
print(min(lengths$len))
print(max(lengths$len))
mean_per_ancestry <- lengths %>%
  group_by(anc) %>%
  summarise(mean_len = mean(len))

med_per_ancestry <- lengths %>%
  group_by(anc) %>%
  summarise(med_len = median(len))
#print(lengths[lengths$len > 248000000,])
print(mean_per_ancestry)
print(med_per_ancestry)
library(ggplot2)

# Create sample data
#tasks <- c("Methylation Data Generation and QC", "Refine imputation and local ancestry assignment", "MeQTL modeling and fine-mapping", "Validation in CAAPA external cohort", "Manuscript writing")
tasks <- c(1,2,3,4,5)
quarter_start <- c(1, 1, 3, 5, 6)
quarter_end <- c(3, 3, 5, 6, 8)

# Combine data into a data frame
data <- data.frame(tasks, quarter_start, quarter_end)

ggplot(data) +
  geom_segment(aes(x = quarter_start, xend = quarter_end, y = as.numeric(tasks), yend = as.numeric(tasks)),  linewidth = 10, position = "stack") +
  labs(x = "Quarters", y = "Tasks") +
  theme(panel.background = element_rect(fill = "white"),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank())
