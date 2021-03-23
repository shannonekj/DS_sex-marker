#!/bin/bash -l
#SBATCH -J cnts_F
#SBATCH -e slurm/j%j.get_counts_all_F_reference.err
#SBATCH -o slurm/j%j.get_counts_all_F_reference.out
#SBATCH -p high 
#SBATCH -c 20
#SBATCH --time=2-22:22:22
#SBATCH --mem=32G

# NOTES: Run samtools depth to generate depth file before

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
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-depths_F_reference"

## other
prefix="all"

## files
cnt_script="/home/sejoslin/git_repos/DS_sex-marker/scripts/get_depth_24v24.pl"
infile="${out_dir}/${prefix}.depth"
outfile="${out_dir}/${prefix}.counts"



###################
###  DO THINGS  ###
###################

echo "Navigating to output directory"
[[ -d ${out_dir} ]] || mkdir -p ${out_dir}
cd ${out_dir}

echo "Counting depths" $(date +%D' '%T)
perl ${cnt_script} ${infile} ${outfile}
echo "   Complete" $(date +%D' '%T)

sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch

