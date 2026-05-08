#!/bin/bash

#### SPRUCE-RF: Phase and call IBD ####

module load shapeit/2.r904
module load vcftools
module load bcftools
module load htslib

DATA=/share/hennlab/projects/khoesan_ancestry/allsamples_phased/stacy_IBD
PHASED_OUT=$DATA/PhasedOut
PHASED_NOREL=$DATA/PhasedOut_NoRelatives
IBD_OUT=$DATA/IBD_out
MAP=/share/hennlab/reference/recombination_maps/genetic_map_b37
MAP2=/share/hennlab/reference/recombination_maps/hapmap_GRCh37_plinkFormat_genetic_map
REF=/share/hennlab/reference/1000G_Phase3_haps-sample-legend/1000GP_Phase3
UNRELATED=/share/hennlab/users/espless/MergedDataEastAfrica/Merge3/KingFiles_Pagani2015_scheinfeldt_geno0.05_mind0.1

mkdir -p $PHASED_OUT $PHASED_NOREL $IBD_OUT

############################################################
# Step 1: Phase with SHAPEIT2
############################################################

for chr in {1..22}; do

shapeit -check \
    -B $DATA/Pagani2015_scheinfeldt_geno0.05_mind0.1_${chr} \
    -M $MAP/genetic_map_chr${chr}_combined_b37.txt \
    --input-ref $REF/1000GP_Phase3_chr${chr}.hap.gz \
                $REF/1000GP_Phase3_chr${chr}.legend.gz \
                $REF/1000GP_Phase3.sample \
    --output-log $PHASED_OUT/chr${chr}.align

shapeit \
    -B $DATA/Pagani2015_scheinfeldt_geno0.05_mind0.1_${chr} \
    -M $MAP/genetic_map_chr${chr}_combined_b37.txt \
    --input-ref $REF/1000GP_Phase3_chr${chr}.hap.gz \
                $REF/1000GP_Phase3.legend.gz \
                $REF/1000GP_Phase3.sample \
    --exclude-snp $PHASED_OUT/chr${chr}.align.snp.strand.exclude \
    --duohmm \
    -W 5 \
    -T 6 \
    -O $PHASED_OUT/chr${chr}.phased \
    --force

############################################################
# Step 2: Convert to VCF
############################################################

shapeit -convert \
    --input-haps $PHASED_OUT/chr${chr}.phased \
    --output-vcf $PHASED_OUT/chr${chr}.phased.vcf

############################################################
# Step 3: Remove relatives
############################################################

vcftools \
    --vcf $PHASED_OUT/chr${chr}.phased.vcf \
    --keep $UNRELATED/kingunrelated_EAfr_vcftools.txt \
    --recode \
    --recode-INFO-all \
    --out $PHASED_NOREL/chr${chr}.norel

############################################################
# Step 4: Call IBD
############################################################

nice java -Xmx10g -jar $PROGS/hap-ibd.jar \
    gt=$PHASED_NOREL/chr${chr}.norel.recode.vcf \
    map=$MAP2/plink.chr${chr}.GRCh37.map \
    out=$IBD_OUT/chr${chr}.ibd

gunzip -f $IBD_OUT/chr${chr}.ibd.ibd.gz

############################################################
# Step 5: Merge segments
############################################################

cat $IBD_OUT/chr${chr}.ibd.ibd | \
java -jar $PROGS/merge-ibd-segments.16May19.ad5.jar \
    $PHASED_NOREL/chr${chr}.norel.recode.vcf \
    $MAP2/plink.chr${chr}.GRCh37.map \
    0.6 1 \
    > $IBD_OUT/chr${chr}.merged.ibd

done
