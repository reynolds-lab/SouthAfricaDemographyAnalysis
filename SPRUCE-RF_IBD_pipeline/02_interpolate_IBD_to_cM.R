############################################################
# Step 1C: interpolate bp → cM
############################################################

for(chr in 1:22) {

mapdir <- "/share/hennlab/projects/khoesan_ancestry/allsamples_phased/stacy_IBD/genetic_map_hg38/"

map <- read.table(
  paste0(mapdir, "chr", chr, "_edited_plink.gmap.map"),
  header = FALSE
)

names(map) <- c("chr", "pos", "cm", "bp")

ibd <- read.table(
  paste0("/share/hennlab/projects/khoesan_ancestry/allsamples_phased/stacy_IBD/IBD_out/merged/za_only_ibd_chr",
         chr, "_merged.ibd")
)

names(ibd) <- c("id1","hap1","id2","hap2","chr","start","end","lod","lod2")

start <- approx(map$bp, map$cm, ibd$start)$y
end   <- approx(map$bp, map$cm, ibd$end)$y

ibd_cm <- data.frame(
  ibd[,1:5],
  start=start,
  end=end,
  lod=ibd$lod
)

write.table(
  ibd_cm,
  paste0("/share/hennlab/projects/khoesan_ancestry/allsamples_phased/stacy_IBD/IBD_out/merged/za_only_ibd_chr",
         chr, "_merged_cM.ibd"),
  row.names=FALSE,
  quote=FALSE,
  sep="\t"
)

}
