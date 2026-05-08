import os

# Define the range of RG and k values
rg_range = range(1, 11)
k_range = range(4, 11)

# Loop through each RG value
for rg in rg_range:
    # Define the directory name
    dir_name = f"RG{rg}_admixture"
    
    # Ensure the directory exists
    os.makedirs(dir_name, exist_ok=True)
    
    # Loop through each k value
    for k in k_range:
        # Define the filename
        file_name = f"filemap_k{k}"
        file_path = os.path.join(dir_name, file_name)
        
        # Open the file for writing
        with open(file_path, 'w') as file:
            # Loop through each iteration
            for i in range(1, 11):
                # Construct the line to write
                line = f"k{k}_{i}\t{k}\t../admixture_ready.all_unrelated_for.RG{rg}.k{k}.r{i}.Q\n"
                # Write the line to the file
                file.write(line)
