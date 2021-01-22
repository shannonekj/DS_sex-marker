#!/bin/bash -l
#SBATCH -J alignRAD
#SBATCH -e slurm/j%j.align_RAD_2_ipa_cb_asm.err
#SBATCH -o slurm/j%j.align_RAD_2_ipa_cb_asm.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=04:00:00
#SBATCH --mem=32G


# NOTE: This script is the skeleton for setting up an aligning RAD data with https://raw.githubusercontent.com/shannonekj/ngs_scripts/master/align_RAD_2019.sh 
## - Directory structure should be:
###     data_dir/library_dirs/index_dirs/*_R?.fastq
## - fastq file names should be formatted as follows: 
###     <library_name>_<index_id>_<barcode>_R?.fastq

###############
###  SETUP  ###
###############

set -e
set -v

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"

### MAKE CHANGES ###
lib_prefix="BMAG0"  # library directory prefix

# directories
script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-raw_data"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-alignments"

# files
reference="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/03-assemblies/sandbox_ipa/DeltaSmelt_combined_salsa2_defaults/salsa_i5_dup/scaffolds_FINAL.fasta"
### END ###


#############
###  RUN  ###
#############

# prep reference genome
#ref_short=$(echo $reference | rev | cut -f1 -d/ | rev)
## make symbolic link to reference genome
#[ -d ${out_dir}/ref_genome ] || mkdir -p ${out_dir}/ref_genome
#cd ${out_dir}/ref_genome
#[ -h ${ref_short} ] || ln -s ${reference} ${ref_short}
## index reference genome
#[ -f ${ref_short}.sa ] || bwa index ${ref_short}; sleep 1m


# make list of individuals to align
cd ${data_dir}
[ -d ${out_dir} ] || mkdir -p ${out_dir}
rm -f ${out_dir}/list
touch ${out_dir}/list
for i in ${lib_prefix}??
do
	echo "Navigating to ${i}"
	cd ${i}
	wc=$(wc -l indexid.list | awk '{print $1}')
	x=1
	while [ $x -le $wc ]
	do
		tagline="sed -n ${x}p indexid.list"
		tag=$($tagline)
		echo ${tag}
		cd ${tag}
		for file in *${tag}*_R1.fastq
		do
			base=$(basename ${file} _R1.fastq)
			echo ${data_dir}/${i}/${tag}/${base}_R1.fastq ${data_dir}/${i}/${tag}/${base}_R2.fastq ${base} >> ${out_dir}/list
		done
		cd ${data_dir}/${i}
		x=$(( $x + 1 ))
	done
	cd ${data_dir}
done

# submit list to alignment script
cd ${script_dir}
[ -f align_RAD_2019.sh ] || wget https://raw.githubusercontent.com/shannonekj/ngs_scripts/master/align_RAD_2019.sh
bash ${script_dir}/align_RAD_2019.sh ${out_dir}/list ${reference} ${out_dir}



end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
