#!/bin/bash -l
#SBATCH -J geno
#SBATCH -e slurm/j%j.call_genotypes.err
#SBATCH -o slurm/j%j.call_genotypes.out
#SBATCH -n 20
#SBATCH -p bigmemh
#SBATCH --time=02-16:00:00
#SBATCH --mem=256G

# Call genotypes from alignments to the MALE assembly

# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate conda env
echo "activating ANGSD conda environment"
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

# files
bamlist="${out_dir}/bamlist"

# other variables
threads=${SLURM_NTASKS}


#############
###  RUN  ###
#############

# make output directory
[ -d ${out_dir} ] || mkdir -p ${out_dir}
cd ${out_dir}

# make bamlist (M first, then F)
ls -l ${bam_dir}/*_M_*sort-n.fixmate-m.sort.markdup-r.bam | awk '{print $9}' > ${bamlist}
ls -l ${bam_dir}/*_F_*sort-n.fixmate-m.sort.markdup-r.bam | awk '{print $9}' >> ${bamlist}

cd ${out_dir}
bash ${script_dir}/call_genotypes.sh ${out_dir} ${bamlist} ${prefix} ${threads}


sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch
end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
