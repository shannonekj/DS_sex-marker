#!/bin/bash -l
#SBATCH -J alignRAD
#SBATCH -e slurm/j%j.align_RAD_2_M_ipa_cb_asm.err
#SBATCH -o slurm/j%j.align_RAD_2_M_ipa_cb_asm.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=04:00:00
#SBATCH --mem=32G


# NOTE: This script is the skeleton for setting up an aligning RAD data with https://raw.githubusercontent.com/shannonekj/ngs_scripts/master/align_RAD_2019.sh 

###############
###  SETUP  ###
###############

# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate conda env
conda activate samtools

# fail on weird errors
set -o nounset
set -o errexit
set -x
set -e

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"

### MAKE CHANGES ###
prefix="RX"  # library directory prefix
# directories
script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-RAD-data"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-alignments_M"
# files
reference="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/04-linkage_map/out_chromonomer/CHRR_integrated.fa"
###  END  ###


#############
###  RUN  ###
#############

# prep reference genome
#ref_short=$(echo $reference | rev | cut -f1 -d/ | rev)
#[ -d ${out_dir} ] || mkdir -p ${out_dir}
#cd ${out_dir}
#[ -h ${ref_short} ] || ln -s ${reference} ${ref_short}
#[ -f ${ref_short}.sa ] || bwa index ${ref_short}; sleep 1m

# make list of individuals to align
[ -d ${out_dir} ] || mkdir -p ${out_dir}
rm -f ${out_dir}/list
touch ${out_dir}/list
cd ${data_dir}
for file in ${prefix}*_R1.fastq
do
    base=$(basename ${file} _R1.fastq)
    echo ${data_dir}/${base}_R1.fastq ${data_dir}/${base}_R2.fastq ${base} >> ${out_dir}/list
done

# submit list to alignment script
echo Navigating to ${script_dir}
cd ${script_dir}
echo Downloading alignment script
[ -f align_RAD_2019.sh ] || wget https://raw.githubusercontent.com/shannonekj/ngs_scripts/master/align_RAD_2019.sh
chmod 755 align_RAD_2019.sh
echo 
bash ${script_dir}/align_RAD_2019.sh ${out_dir}/list ${reference} ${out_dir}


end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
