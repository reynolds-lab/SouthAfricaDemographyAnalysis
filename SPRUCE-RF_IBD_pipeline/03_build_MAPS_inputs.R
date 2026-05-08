############################################################
# Step 1E: build MAPS inputs
############################################################

meta <- read.table("metadata.txt", header=TRUE)

ibd <- read.table("za_only_ibd_allchr_merged_cM.ibd", header=TRUE)

ibd_data <- data.frame(
  id1 = paste0(ibd$id1, "_1"),
  id2 = paste0(ibd$id2, "_2"),
  start = ibd$start,
  end = ibd$end
)

ids <- rep(paste0(meta$IID, "_", meta$IID), each=2)
locs <- rep(paste(meta$Lat, meta$Long), each=2)

n <- length(ids)

ibd_summary <- matrix(0, n, n)
rownames(ibd_summary) <- ids
colnames(ibd_summary) <- ids

lengths <- ibd_data$end - ibd_data$start

selected <- which(lengths > 2 & lengths < 6)

for(i in selected){
  id1 <- ibd_data$id1[i]
  id2 <- ibd_data$id2[i]

  if(id1 %in% ids & id2 %in% ids){
    ibd_summary[id1,id2] <- ibd_summary[id1,id2] + 1
    ibd_summary[id2,id1] <- ibd_summary[id1,id2]
  }
}

write.table(ibd_summary, "2_6.sims", quote=FALSE, sep=" ", col=FALSE, row=FALSE)
write.table(locs, "2_6.coord", quote=FALSE, sep=" ", col=FALSE, row=FALSE)
