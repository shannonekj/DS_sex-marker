#!/bin/bash
#BATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J novoFem
#SBATCH -e 02.deNovo_C_novoAlign_femaleOnly_relaxed.j%j.err
#SBATCH -o 02.deNovo_C_novoAlign_femaleOnly_relaxed.j%j.out
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
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-RAD_deNovo_relaxed/femaleOnly"

# files
prefix="SexMarker_F_relaxed"


#############
###  RUN  ###
#############
echo "Running RAD_deNovo_novoAlign.sh"
echo ""
bash ${script_dir}/RAD_deNovo_novoAlign.sh ${data_dir} ${prefix}
