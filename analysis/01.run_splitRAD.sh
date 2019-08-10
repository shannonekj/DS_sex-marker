#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J splitRD
#SBATCH --array=1
#SBATCH -e 01.run_splitRAD.j%j.err
#SBATCH -o 01.run_splitRAD.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --mem=32G
#SBATCH --time=5-20:00:00

set -e # exit upon failing
set -x # trace commands after expansion before execution



###########
## NOTE: ##  This project uses the LAST 48 wells on a plate--adjust barcodes accordingly.
###########

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"
THREADS=${SLURM_NTASKS}
echo "Threads: $THREADS"
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)
echo "Mem: ${MEM}Gb"



###############
###  SETUP  ###
###############

project="DS_sex-marker"
barcodes=(CCGTCC)
x=${SLURM_ARRAY_TASK_ID}
b=${barcodes[$(( $x - 1 ))]}
echo "Processing barcode : ${b}"
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-raw_data/BMAG051"
script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"
master_scripts="/home/sejoslin/scripts"



#############
###  RUN  ###
#############
bash ${script_dir}/splitRAD.sh ${project} ${b} ${data_dir} ${master_scripts}



end=`date +%s`
runtime=$((end-start))
echo Runtime: $runtime
