#!/bin/bash -l
#SBATCH -J geno
#SBATCH -e slurm/j%j.call_genotypes.err
#SBATCH -o slurm/j%j.call_genotypes.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=16:00:00
#SBATCH --mem=32G

# Call genotypes from alignments to the MALE assembly

# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate conda env
conda activate ANGSD

# fail on weird errors
set -o nounset
set -o errexit
set -x
set -e

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"


###############
###  SETUP  ###
###############
proj="DS_sex-marker"
sex="M"
prefix="genotypes_${sex}_reference"

# directories
script_dir="/home/sejoslin/git_repos/${proj}/scripts"
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker"
bam_dir="${data_dir}/00-alignments_${sex}"
out_dir="${data_dir}/02-genotypes"

bamlist="${out_dir}/bamlist"

#############
###  RUN  ###
#############

# make output directory
[ -d ${out_dir} ] || mkdir -p ${out_dir}

# make bamlist (F first, then F)
cd ${bam_dir}
ls -l *_M_*sort-n.fixmate-m.sort.markdup-r.bam | awk '{print $9}' > ${bamlist}
ls -l *_F_*sort-n.fixmate-m.sort.markdup-r.bam | awk '{print $9}' >> ${bamlist}

cd ${out_dir}
bash ${script_dir}/call_genotypes.sh ${out_dir} ${bamlist} ${prefix}

end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
