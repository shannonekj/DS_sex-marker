#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J qualFILT
#SBATCH -e 02.deNovo_B_qualityFilter_maleOnly.j%j.err
#SBATCH -o 02.deNovo_B_qualityFilter_maleOnly.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=02:00:00

set -e 
set -v 

##  VARIABLES  ##
# directories
code_dir="/home/sejoslin/scripts"
script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"
data_dir="/home/sejoslin/projects/sexMarker/data"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-RAD_deNovo/maleOnly"

# other
best_file="${out_dir}/SexMarker_line_count.maleOnly.best"
prefix="SexMarker"


##  RUN  ##
bash ${script_dir}/RAD_deNovo_qualityFilter.sh ${data_dir} ${out_dir} ${code_dir} ${prefix} ${best_file}



