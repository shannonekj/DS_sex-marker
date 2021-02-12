#!/bin/bash
#BATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J novo
#SBATCH -e slurm/02.deNovo_C_novoAlign_maleOnly.j%j.err
#SBATCH -o slurm/02.deNovo_C_novoAlign_maleOnly.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines



###############
###  SETUP  ###
###############

echo "Setting up variables"

# directories
script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-RAD_deNovo/maleOnly"

# files
prefix="SexMarker_M"


#############
###  RUN  ###
#############
echo "Running RAD_deNovo_novoAlign.sh"
echo ""
bash ${script_dir}/RAD_deNovo_novoAlign.sh ${data_dir} ${prefix}
