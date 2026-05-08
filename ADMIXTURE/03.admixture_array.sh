#!/bin/bash

#SBATCH -c 300 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --ntasks 1 # specify how many Slurm tasks
#SBATCH -J admixture  # job name
#SBATCH --mem 500000 # Memory pool for all cores
#SBATCH --time=16-00:00:00 #expected time of completion
#SBATCH -p production # Partition to submit to--generally gc
#SBATCH --mail-type=ALL # Type of email notification- BEGIN,END,FAIL,ALL.
#SBATCH --mail-user=dralhindi@ucdavis.edu 
#SBATCH --array=8-9


module load admixture
cd /share/hennlab/projects/admixture/

echo $SLURM_ARRAY_TASK_ID
n=3
k=$(($SLURM_ARRAY_TASK_ID + $n))

for x in {1..10}; do
    for i in {1..10}; do 
        file="admixture_ready.all_unrelated_for.RG${x}.k${k}.r${i}.Q"
        if [ -f "$file" ]; then
            echo "File $file exists. Skipping..."
            continue
        fi
        
        echo "working on admixture_ready.all_unrelated_for.RG${x}.k${k}.r${i}"
        admixture -s time admixture_ready.all_unrelated_for.RG${x}.bed ${k} --cv=5 -j300 | tee admixture_ready.all_unrelated_for.RG${x}.k${k}.r${i}.out
        mv admixture_ready.all_unrelated_for.RG${x}.${k}.P admixture_ready.all_unrelated_for.RG${x}.k${k}.r${i}.P
        mv admixture_ready.all_unrelated_for.RG${x}.${k}.Q admixture_ready.all_unrelated_for.RG${x}.k${k}.r${i}.Q
    done
done
