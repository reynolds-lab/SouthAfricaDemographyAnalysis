# Load necessary libraries
library(reshape2)
library(data.table)

#input arguments
args = commandArgs(TRUE)
segfile.path = args[1] # KING .seg file
t = as.numeric(args[2]) # a threshold of defining relatedness, ex for second degree: 0.25
prefix = args[3] # prefix for the bed/bim/fam files, ex: merged.geno05.LD50.mind10


# Read in KING seg file
segfile <- read.table(segfile.path, header = T, stringsAsFactors = F)

# There will always be missing inds in the ID columns to avoid redundancy in results
# but we want those for a full relationship matrix so we will cast both ways
relmat.temp1 <- acast(segfile, ID1~ID2, value.var = "PropIBD")
relmat.temp2 <- acast(segfile, ID2~ID1, value.var = "PropIBD")

# Combine the matrices
relmat.tempfull <- merge(relmat.temp1, relmat.temp2, all=TRUE, by="row.names")

# Remove temp ".x" notation from relationship matrix
colnames(relmat.tempfull) <- gsub(x = colnames(relmat.tempfull), pattern = "\\.x", replacement = "") 

# Isolate ".y" columns into their own matrix for combining
relmat.tempfull.y<-relmat.tempfull[, grep(".y", colnames(relmat.tempfull))]

# remove ".y" columns from the other matrix
relmat.tempfull.x<- relmat.tempfull[, -grep(".y", colnames(relmat.tempfull))]

# Remove temp ".y" notation from relationship matrix
colnames(relmat.tempfull.y) <- gsub(x = colnames(relmat.tempfull.y), pattern = "\\.y", replacement = "") 
relmat.tempfull.y<-cbind(relmat.tempfull$Row.names,relmat.tempfull.y)
colnames(relmat.tempfull.y)[1]<-colnames(relmat.tempfull)[1]

# combine everything into a proper relationship matrix
relmat.full<-as.data.frame(dcast.data.table(
  merge(
    ## melt the first data.frame and set the key as ID and variable
    setkey(melt(as.data.table(relmat.tempfull.x), id.vars = "Row.names"), Row.names, variable), 
    ## melt the second data.frame
    melt(as.data.table(relmat.tempfull.y), id.vars = "Row.names"), 
    ## you'll have 2 value columns...
    all = TRUE)[, value := ifelse(
      ## ... combine them into 1 with ifelse
      is.na(value.x), value.y, value.x)], 
  ## This is your reshaping formula
  Row.names ~ variable, value.var = "value"))

# Make first column the rownames instead
rownames(relmat.full) <- relmat.full[,1]
relmat.full[,1] <- NULL

#reorder so it's a proper matrix
mat <- relmat.full[ order(row.names(relmat.full)),order(colnames(relmat.full)) ]

#######
# first, find out the group of absolute unrelatedness, i.e. not related to anyone else
#######
absolute.unrelate<-c()
for (i in 1:nrow(mat)){
  if (max(mat[,i],na.rm = T)<t) absolute.unrelate<-c(absolute.unrelate, rownames(mat)[i])
}



#######
# second, design running groups based on relatedness
#######

index.related <- which(!rownames(mat)%in%absolute.unrelate)
temp<-mat[index.related,]
related.mat <- temp[,index.related]
rm(temp)
related.id<-rownames(related.mat)

#clustering related individuals (not really)
cluster.relate <- list() 
N.group <- 1 # initiation of the number of groups

# note: a might be related to b and c, while b might be related to a, c and e
# these would be treated as two clusters : {a: b, c} and {b: a, c, e}
for (i in 1:length(related.id)){
  cluster.relate[[i]] <- related.id[which(related.mat[i,] > t)]
  if (length(cluster.relate[[i]]) > N.group) N.group <- length(cluster.relate[[i]])
}

N.group<-N.group+1

#start to put them into groups 
start.pos <- 1 # start position to put individual in to groups 
groups <- rep(list(NA),N.group)

for (i in 1:length(related.id)){
  # Find out which existed groups already have relatives of the new id
  index.NotPut <- which(lapply(lapply(groups, FUN=intersect, y = cluster.relate[[i]]), FUN=length)!=0)
  if(length(index.NotPut)==0) index.NotPut <- c(-1) 
  while(start.pos%in%index.NotPut){
    start.pos <- start.pos %% N.group +1 # if pos = N.group, next is 1
  }
  groups[[start.pos]] <- c(groups[[start.pos]], related.id[i])
  start.pos <- start.pos %% N.group +1 
  rm(index.NotPut)
}

# trim the first NA in the list of groups
for (i in 1:N.group){
  groups[[i]]<- groups[[i]][-1]
}



#########
# output 
#########

fam_data <- read.table(paste(prefix, ".fam", sep = ""), header = FALSE, stringsAsFactors = FALSE)

if(length(absolute.unrelate)!=0) {
  write.table(absolute.unrelate, paste(prefix, ".unrelated.allRGs.list", sep=""), col.names=F, row.names=F, quote=F, sep='\n')
  unrelINDS_list <- read.table(paste(prefix, ".unrelated.allRGs.list", sep = ""), header = FALSE, stringsAsFactors = FALSE)
  matched_rows <- fam_data[fam_data$V2 %in% unrelINDS_list$V1, ]
  write.table(matched_rows, paste(prefix, ".unrelated.allRGs.list", sep=""), col.names=F, row.names=F, quote=F, sep=' ')
}

for (i in 1:N.group){
  write.table(groups[[i]], paste(prefix,".RG",i,".inds.list", sep=""), col.names=F,row.names=F, quote=F, sep='\n')
  current_file <- read.table(paste(prefix, ".RG", i, ".inds.list", sep = ""), header = FALSE, stringsAsFactors = FALSE)
  matched_rows <- fam_data[fam_data$V2 %in% current_file$V1, ]
  write.table(matched_rows, paste(prefix,".RG",i,".inds.list", sep=""), col.names=F,row.names=F, quote=F, sep=' ')
}
