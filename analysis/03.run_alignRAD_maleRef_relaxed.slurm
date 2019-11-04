#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J aln2Mal
#SBATCH -e 03.run_alignRAD_maleRef_relaxed.j%j.err
#SBATCH -o 03.run_alignRAD_maleRef_relaxed.j%j.out
#SBATCH -p high
#SBATCH --time=00:02:22
#SBATCH --mem=32G

set -e
set -v

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"



###############
###  SETUP  ###
###############
proj="DS_sex-marker"
fq_prefix="RX"
lib_prefix="BMAG0"
prefix="SexMarker_M_relaxed"

# directories
script_dir="/home/sejoslin/git_repos/${proj}/scripts"
data_dir="/home/sejoslin/projects/sexMarker/data"
bam_dir="/group/millermrgrp2/shannon/projects/${proj}/02-RAD_alignments_relaxed/maleRef"

# files
reference="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-RAD_deNovo_relaxed/maleOnly/${prefix}.simple._1.loci"

# other
priority="med"



#############
###  RUN  ###
#############
bash ${script_dir}/alignRAD.R1.sh ${data_dir} ${bam_dir} ${lib_prefix} ${fq_prefix} ${proj} ${reference} ${priority}



end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
