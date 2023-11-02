#!/bin/bash -l
#SBATCH -J sort_M
#SBATCH -e slurm/j%j.sort_counts_all_M_reference_bowtie2.err
#SBATCH -o slurm/j%j.sort_counts_all_M_reference_bowtie2.out
#SBATCH -p high 
#SBATCH -c 20
#SBATCH --time=22:22:22
#SBATCH --mem=32G

# NOTES: Run samtools depth to generate depth file before
#        Run get_counts_24v24.pl to generate counts file prior to running

###############
###  SETUP  ###
###############

# fail on weird errors
set -o nounset
set -o errexit
set -x


# variables

## directories
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-depths_M_reference_bowtie2"

## other
prefix="all"

## files
infile="${out_dir}/${prefix}.counts"
outfile="${out_dir}/${prefix}.counts.sorted"


###################
###  DO THINGS  ###
###################

echo "Navigating to output directory"
[[ -d ${out_dir} ]] || mkdir -p ${out_dir}
cd ${out_dir}

echo "Sorting counts file" $(date +%D' '%T)
sort -nrk 9 ${infile} >> ${outfile}
echo "    Complete!"

sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch

