#!/bin/bash
#SBATCH -J putY2G
#SBATCH -e slurm/j%j.align_putative_y.err
#SBATCH -o slurm/j%j.align_putative_y.out
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=48gb
#SBATCH --time=01-04:08:16
#SBATCH -p high


###############
###  SETUP  ###
###############
# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate conda env
conda activate samtools

# fail on weird errors
set -o nounset
set -o errexit
set -x

reference="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/04-linkage_map/out_chromonomer/CHRR_integrated.fa"
put_y="/group/millermrgrp2/shannon/projects/2020-shannon-fish-sex/data/contigs.female_absent.fa"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/05-putative_y"
prefix_out="putative_y"



###################
###  DO THINGS  ###
###################

# make output directory
[ -d ${out_dir} ] || mkdir -p ${out_dir}
cd ${out_dir}

# symlink ref
ref_short=$(echo $reference | rev | cut -f1 -d/ | rev)
[ -h ${ref_short} ] || ln -s ${reference} ${ref_short}
bwa index ${ref_short}

# align putative Y data to male assembly...
bwa mem -B 40 -O 60 -E 10 -L 50 -t ${SLURM_NTASKS} ${ref_short} ${put_y} | samtools view -Sb | samtools sort -o ${out_dir}/${prefix_out}.sort.bam
samtools index ${out_dir}/${prefix_out}.sort.bam
