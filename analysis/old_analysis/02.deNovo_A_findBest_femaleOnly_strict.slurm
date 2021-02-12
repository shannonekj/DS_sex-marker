#!/bin/bash
#BATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J findBEST
#SBATCH -e slurm/02.deNovo_A_findBest_femaleOnly.%j.err
#SBATCH -o slurm/02.deNovo_A_findBest_femaleOnly.%j.out
#SBATCH -c 2
#SBATCH -p high
#SBATCH --time=00:11:11

set -e 
set -v 

##  VARIABLES  ##
# directories
script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"
data_dir="/home/sejoslin/projects/sexMarker/data"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-RAD_deNovo/femaleOnly"

# other
prefix="SexMarker_F"
n="4"


##  RUN  ##
bash ${script_dir}/findBestInd.sh ${data_dir} ${out_dir} ${prefix} ${n} 

# make best file with only females
cd ${out_dir}
grep _F_ SexMarker_F_line_count.all.sorted >> SexMarker_F_line_count.maleOnly.sorted
head -${n} SexMarker_F_line_count.maleOnly.sorted >> SexMarker_F_line_count.maleOnly.best
