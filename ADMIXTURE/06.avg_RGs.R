library(dplyr)
library(purrr)
library(tidyr)

input_dir <- "/share/hennlab/projects/admixture/results"
output_dir <- "/share/hennlab/projects/admixture/results"

k_values <- 11

for (k in k_values) {
  tryCatch({
    file_pattern <- paste0("admixture_ready.all_unrelated_for.RG(1|2|3|4|5|6|7|8|9|10)_k", k, "_withFam.Q")
    files <- list.files(path = input_dir, pattern = file_pattern, full.names = TRUE)

    if (length(files) == 0) {
      cat("No files found for k =", k, "\n")
      next
    }

    # Read and combine data from all files
    all_data <- files %>%
      map_dfr(~ {
        data <- read.table(.x, header = TRUE, stringsAsFactors = FALSE)
        data %>%
          mutate(Sample = trimws(Sample))  # Ensure Sample IDs are consistent
      })

    # Check if all_data has the expected columns
    cat("Columns in all_data:\n")
    print(colnames(all_data))

    # Step 2: Compute the averages for each Sample
    averaged_data <- all_data %>%
      group_by(Pop, Sample) %>%
      summarize(across(where(is.numeric), mean, .names = "avg_{.col}"), .groups = 'drop') %>%
      rename_with(~ gsub("^avg_", "", .), starts_with("avg_"))

    # Check if averaged_data has the expected columns
    cat("Columns in averaged_data:\n")
    print(colnames(averaged_data))

    # Step 3: Format and write the final output
    formatted_data <- averaged_data %>%
      mutate(across(where(is.numeric), ~ sprintf("%.5f", .)))

    final_output_file <- file.path(output_dir, paste0("admixture_ready.all_unrelated_k", k, "_withFam.2.Q"))
    write.table(formatted_data, final_output_file, quote = FALSE, row.names = FALSE, sep = " ")
    cat("Averaging complete and saved to:", final_output_file, "\n")
  }, error = function(e) {
    cat("An error occurred for k =", k, ":", conditionMessage(e), "\n")
  })
}
