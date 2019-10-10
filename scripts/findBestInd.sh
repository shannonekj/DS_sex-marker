#!/bin/bash -l

#       This script will find the individuals with the most reads.
#	INPUT: Raw FASTQ files
#	OUTPUT: Sorted list of individual files and the number of reads sequenced

set -x
set -e
set -v


###############
###  SETUP  ###
###############

echo "Setting up variables"

# external
DATA_dir=$1     # directory where raw split fastq files are located
OUT_dir=$2	# directory to direct output to
PREFIX=$3	# Prefix of project
N=$4		# number of individuals to select

# internal 
sum_file="${OUT_dir}/${PREFIX}_line_count.all"

echo "Data directory: ${DATA_dir}"
echo "Output directory: ${OUT_dir}"
echo "Prefix: ${PREFIX}"
echo "N Best Individuals: ${N}"
echo ""

###################
###  DO THINGS  ###
###################

mkdir -p ${OUT_dir}
touch ${sum_file}
cd ${DATA_dir}

for i in BMAG0??
do
	cd ${i}
	echo "Entering:" ${i}
	echo "Finding line counts in:"
	for library in 04_split_wells.${i}.??????.sh # MAKE SURE FORMAT IS THE SAME
	do
		index=$(echo ${library} | cut -d. -f3)
		echo "    ${index}"
		cd ${index}
		for j in *_R1.fastq
		do
			echo $j
			full=$(wc -l $j)
			line_count=$(echo ${full} | awk '{print $1}')
			base=$(basename ${j} _R1.fastq)
		        echo -e ${line_count}"\t"${base}"\t"${i}"\t"${index}>> ${sum_file}
		done
		cd ../
	done
	cd ../
done

sort -n -r ${sum_file} > ${sum_file}.sorted


# grab the best
n=$(( $N + 1 ))
head -${n} ${sum_file}.sorted >> ${sum_file}.best
sed -i '1d' ${sum_file}.best



