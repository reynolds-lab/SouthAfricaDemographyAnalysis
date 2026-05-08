#!/bin/bash

# This script prepares admixture input files by taking in output files made by running_groups.r
# It will use them to generated plink files for each running group as well as 
prefix="$1"
total_RG="$2"

module load plink

for i in $(seq 1 $total_RG); do
    # cat "${prefix}.unrelated.allRGs.list" "${prefix}.RG${i}.inds.list" > "${prefix}.all_unrelated_for.RG${i}.list"
    plink --bfile "${prefix}" --keep "${prefix}.all_unrelated_for.RG${i}.list" --make-bed --out "${prefix}.all_unrelated_for.RG${i}"
done
