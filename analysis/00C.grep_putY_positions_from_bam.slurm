#!/bin/bash
#SBATCH -J putY2G
#SBATCH -e slurm/j%j.grep_putative_y.err
#SBATCH -o slurm/j%j.grep_putative_y.out
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=48gb
#SBATCH --time=02-04:08:16
#SBATCH -p high


###############
###  SETUP  ###
###############
set -x

out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/05-putative_y"



###################
###  DO THINGS  ###
###################

# make output directory
[ -d ${out_dir} ] || mkdir -p ${out_dir}
cd ${out_dir}

x=1
n=$(wc -l putative_y.sort.sam | awk '{print $1}')
while [ $x -le $n ]
do
    chr=$(sed -n ${x}p putative_y.sort.sam | awk '{print $3}')
    pos=$(sed -n ${x}p putative_y.sort.sam | awk '{print $4}')
    call="grep -P ${chr}\"\t\"${pos} /group/millermrgrp2/shannon/projects/DS_sex-marker/01-depths_M_reference/all.counts >> putative_y_rad_depths.counts"
    echo $call
    eval $call
    x=$(( $x + 1 ))
done

