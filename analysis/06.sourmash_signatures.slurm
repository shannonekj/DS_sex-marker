#!/bin/bash
#SBATCH -J srmsh_sx
#SBATCH -e slurm/06.sourmash_signatures.j%j.err
#SBATCH -o slurm/06.sourmash_signatures.j%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=16gb
#SBATCH --time=01-24:24:24
#SBATCH -p high

###############
###  SETUP  ###
###############
# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate conda env
conda activate sourmash

# fail on weird errors
set -o nounset
set -o errexit
set -x

tenx_m_dir="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/00-raw_data/data-10X_M"
tenx_m_r1="Male2_S63_L004_R1_001.fastq.gz"
tenx_m_r2="Male2_S63_L004_R2_001.fastq.gz"
tenx_f_dir="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/00-raw_data/data-10X_F"
tenx_f_r1="Smelt2F_S432_L004_R1_001.fastq.gz"
tenx_f_r2="Smelt2F_S432_L004_R2_001.fastq.gz"

out_dir="/home/sejoslin/git_repos/DS_sex-marker/results/sourmash"

###################
###  DO THINGS  ###
###################

# make output directory
mkdir -p ${out_dir}
cd ${out_dir}

# sym link tenx files
ln -s ${tenx_m_dir}/${tenx_m_r1} ${tenx_m_r1}
ln -s ${tenx_m_dir}/${tenx_m_r2} ${tenx_m_r2}
ln -s ${tenx_f_dir}/${tenx_f_r1} ${tenx_f_r1}
ln -s ${tenx_f_dir}/${tenx_f_r2} ${tenx_f_r2}


# sourmash compute
sourmash compute -k 21,31,51 --scaled 1000 --track-abundance *.fastq.gz -o sample.sig

