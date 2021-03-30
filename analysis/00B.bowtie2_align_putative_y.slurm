#!/bin/bash
#SBATCH -J putY2G
#SBATCH -e slurm/j%j.bowtie2_align_putative_y.err
#SBATCH -o slurm/j%j.bowtie2_align_putative_y.out
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
conda activate bowtie2

# fail on weird errors
set -o nounset
set -o errexit
set -x

reference="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/04-linkage_map/out_chromonomer/CHRR_integrated.fa"
put_y="/group/millermrgrp2/shannon/projects/2020-shannon-fish-sex/data/contigs.female_absent.fa"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/05-putative_y_bowtie2"
prefix_out="putative_y"



###################
###  DO THINGS  ###
###################

# make output directory
[ -d ${out_dir} ] || mkdir -p ${out_dir}
cd ${out_dir}

# symlink ref
ref_short=$(echo $reference | rev | cut -f1 -d/ | rev)
ref_pre=$(echo $ref_short | cut -f1 -d.)
[ -h ${ref_short} ] || ln -s ${reference} ${ref_short}

# build database
bowtie2-build -f ${ref_short} ${ref_pre}

# align putative Y to reference
bowtie2 --end-to-end -p ${SLURM_NTASKS} -x ${ref_pre} -r ${put_y} -S ${prefix_out}.sam

# create sorted BAM
conda activate samtools
samtools view -Sb ${prefix_out}.sam > ${prefix_out}.bam
samtools sort ${prefix_out}.bam > ${prefix_out}.sorted.bam
samtools index ${prefix_out}.sorted.bam


