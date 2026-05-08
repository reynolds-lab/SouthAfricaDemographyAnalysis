#!/bin/bash

## This script takes in
## (1) admixture running groups and annotates it with fam and sample ID
## (2) change all Indonesian sample IDs to "Indonesian"
## (3) looks at the highest value of the top individual in each column, and then annotates each column with the fam ID of those indiviuals

# Define your data directory and output
####****************************************************************************************************####
data_dir='/share/hennlab/projects/admixture'
mode_file='RG_majormodes.txt'
output_dir='/share/hennlab/projects/admixture/results'
####****************************************************************************************************####

for i in {1..10}; do
  for k in {4..12}; do
    cat /share/hennlab/projects/admixture/RG${i}_admixture/RG${i}_k${k}_results/result_summary.txt >> RG${i}_admixture/result_summary.test.txt
  done
  echo "done with RG${i}"
done


#create major modes file
for rg in {1..10}; do #add if statement to see if it exists or not
 awk -v rg="$rg" '/Major mode:/{print substr($3,2), rg}' ${data_dir}/RG${rg}_admixture/result_summary.test.txt >> ${data_dir}/RG_majormodes.txt
done
echo "major modes file created"


#get number of lines in major modes file
line_count=`wc -l ${data_dir}/${mode_file} | awk '{print$1}'`



#loop through each line of major modes file
#and add the pop/ind information from the fam files to the Q files
#makes a new file with this info (output_file)
for (( c=1; c<=$line_count; c++ )); do
  echo ${c}
  rg_num=`sed "${c}q;d" ${mode_file} | awk '{print$2}'`
  fam_file="${data_dir}/admixture_ready.all_unrelated_for.RG${rg_num}.fam"
  k_val=`sed "${c}q;d" ${mode_file} | awk '{print$1}' | cut -d "_" -f 1`
  r_val=`sed "${c}q;d" ${mode_file} | awk '{print$1}' | cut -d "_" -f 2`
  q_file="${data_dir}/admixture_ready.all_unrelated_for.RG${rg_num}.k${k_val}.r${r_val}.Q" 
  output_file="${output_dir}/admixture_ready.all_unrelated_for.RG${rg_num}_k${k_val}_withFam.Q"
  
  # Combine columns 1 and 2 from the fam file with all columns from the q file
  awk '{getline q < "'${q_file}'"; print $1, $2, q}' "${fam_file}" > "${output_file}"
  echo ${output_file}
done

echo "modified Q files created"

# Loop through the files in the current directory that end with _withFam.Q
for file in "$output_dir"/*_withFam.Q; do
  if [ -e "$file" ]; then
    # Determine the header for each column
    header="Pop Sample"
    for i in $(seq 3 "$(head -n 1 "$file" | awk '{print NF}')"); do
      # Get the Pop with the highest value in column $i
      pop=$(tail -n +2 "$file" | awk -v col=$i '{print $col,$1}' | sort -k1,1nr | head -n 1 | awk '{print $2}')
      # Append the Pop to the header
      header="$header $pop"
    done

    modified_file="${file}_modified"
    cp "$file" "$modified_file"
    sed -i "1i $header" "$modified_file"
    mv "$modified_file" "$file"
    echo "header added to ${file}"
  fi
done

