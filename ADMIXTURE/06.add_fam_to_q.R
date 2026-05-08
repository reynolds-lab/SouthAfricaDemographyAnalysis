RG_numbers <- 1:10
k_numbers <- 11
r_numbers <- 1:10

for (RG_number in RG_numbers) {
  fam_filename <- paste0("/share/hennlab/projects/admixture/admixture_ready.all_unrelated_for.RG", RG_number, ".fam")

  if (file.exists(fam_filename)) {
    fam_data <- read.table(fam_filename, sep = " ")
    fam_data <- fam_data[, 1:2]
    
    for (k_number in k_numbers) {
      for (r_number in r_numbers) {
        Q_filename <- paste0("admixture_ready.all_unrelated_for.RG", RG_number, ".k", k_number, ".r", r_number, ".Q")
        
        if (file.exists(Q_filename)) {
          Q_data <- read.table(Q_filename, sep = " ")
          combined_data <- cbind(fam_data, Q_data)
          combined_data[, 3:ncol(combined_data)] <- lapply(combined_data[, 3:ncol(combined_data)], function(x) format(x, scientific = FALSE))          
          combined_filename <- paste0("/share/hennlab/projects/admixture/results/admixture_ready.all_unrelated_for.RG", RG_number, "_k", k_number, "_r", r_number, "_withFam.txt")
          write.table(combined_data, combined_filename, sep = " ", row.names = FALSE, col.names = FALSE, quote = FALSE)
          cat("Combined", fam_filename, "with", Q_filename, "\n")
        } else {
          cat("Could not find", Q_filename, ", moving on...\n")
        }
      }
    }
  } else {
    cat("Could not find", fam_filename, ", moving on...\n")
  }
}
