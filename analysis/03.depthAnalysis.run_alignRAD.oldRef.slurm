#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J alignRAD
#SBATCH -e slurm/03.run_alignRAD.j%j.err
#SBATCH -o slurm/03.run_alignRAD.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=04:00:00
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

# directories
script_dir="/home/sejoslin/git_repos/${proj}/scripts"
data_dir="/home/sejoslin/projects/sexMarker/data"
bam_dir="${data_dir}/RAD_alignments"

# files
reference="/group/millermrgrp2/shannon/projects/genome_Hypomesus-transpacificus/data/04-supernova_out/60x/A/Hypomesus-transpacificus_10X_F_A.pseudohap2.1.fasta"


#############
###  RUN  ###
#############
gunzip ${reference}.gz

bash ${script_dir}/alignRAD.all.sh ${data_dir} ${bam_dir} ${lib_prefix} ${fq_prefix} ${proj} ${reference}

end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
