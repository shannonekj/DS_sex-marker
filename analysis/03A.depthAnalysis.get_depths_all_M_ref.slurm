#!/bin/bash -l
#SBATCH -J dpth_M
#SBATCH -e slurm/j%j.get_depths_all_M_reference.err
#SBATCH -o slurm/j%j.get_depths_all_M_reference.out
#SBATCH -p high 
#SBATCH -c 20
#SBATCH --time=2-22:22:22
#SBATCH --mem=32G

###############
###  SETUP  ###
###############
# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh
conda activate samtools

# fail on weird errors
set -o nounset
set -o errexit
set -x

# variables
## directories
bam_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-alignments_M"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-depths_M_reference"
## files
reference="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/04-linkage_map/out_chromonomer/CHRR_integrated.fa"
## other
bam_suffix=".sort-n.fixmate-m.sort.markdup-r.bam"

###################
###  DO THINGS  ###
###################

[[ -d ${out_dir} ]] || mkdir -p ${out_dir}
cd ${out_dir}

# symlink reference
ref_short=$(echo ${reference} | rev | cut -d/ -f1 | rev)
#ln -s ${reference} ${ref_short}
#samtools faidx ${ref_short}

# make list bam files for each sex
ls -l ${bam_dir}/*_M_*${bam_suffix} | awk '{print $9}' > all.bamlist
ls -l ${bam_dir}/*_F_*${bam_suffix} | awk '{print $9}' >> all.bamlist

# make BED file of all loci
awk 'BEGIN {FS="\t"}; {print $1 FS "0" FS $2}' ${ref_short}.fai >> ${ref_short}.bed
# make list of loci
grep ">" ${ref_short} >> ${out_dir}/loci.list


# GET DEPTH
samtools depth -aa -b ${ref_short}.bed -f all.bamlist -o all.depth



