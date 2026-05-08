#!/bin/bash

#SBATCH -c 50               
#SBATCH -N 1                
#SBATCH --ntasks 1         
#SBATCH -J gnomix_6    
#SBATCH --mem 80000        
#SBATCH --time=01-00:00:00  
#SBATCH -p production       
#SBATCH --mail-type=ALL     
#SBATCH --mail-user=dralhindi@ucdavis.edu
#SBATCH --array=1-22        

source /share/hennlab/progs/miniconda3/etc/profile.d/conda.sh
conda activate gnomix2
export MPLCONFIGDIR=/share/hennlab/progs/miniconda3/envs/gnomix/var/matplotlib
wdir="/share/hennlab/projects/khoesan_ancestry"

timestamp() {
  date +"%T" 
}

chr=${SLURM_ARRAY_TASK_ID}

for i in {1..14}; do
  echo "working on chr${i}"
  echo "working on chr${i}" > ${wdir}/output6_SAref/chr${i}/chr${i}_w4_smooth.log
  echo "chr${i} start time:" >> ${wdir}/output6_SAref/chr${i}/chr${i}_w4_smooth.log
  timestamp >> ${wdir}/output6_SAref/chr${i}/chr${i}_w4_smooth.log

  python3.7 ${wdir}/gnomix/gnomix.py \
    ${wdir}/reference/chr${i}.output6.query.SA_ref.vcf.gz \
    ${wdir}/output6_SAref/chr${i} \
    ${i} \
    True \
    ${wdir}/genetic_map_hg38/chr${i}.gmap.tsv \
    ${wdir}/reference/chr${i}.output6.reference.noSA_ref.vcf.gz \
    ${wdir}/output6_SAref/smap_from_vcf.smap \
    ${wdir}/gnomix/configs/config_array_window4_smooth.yaml >> ${wdir}/output6_SAref/chr${i}/chr${i}_w4_smooth.log 2>&1

  echo "chr${i} end time:" >> ${wdir}/output6_SAref/chr${i}/chr${i}_w4_smooth.log
  timestamp >> ${wdir}/output6_SAref/chr${i}/chr${i}_w4_smooth.log
done
