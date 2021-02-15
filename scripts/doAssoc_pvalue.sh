#!/bin/bash -l

#	This script will run an association test.
# 	Neccessary file(s):
#		Phenotype file with case/control status (vertical list of individuals where control = 0 and case = 1)

set -e
set -v


###############
###  SETUP  ###
###############

echo "Setting up modules" $(date +%D' '%T)
module load bio
angsd -version # this doesn't actually print a version number in one line but rather prints an error that contains the version number in it

echo "Setting up variables" $(date +%D' '%T)
# external
OUT_dir=$1	# directory where output will be written to
BAMLIST=$2	# list of bamfiles (global path)
PROJ=$3		# project ID
YBIN=$4		# phenotype file



###################
###  DO THINGS  ###
###################

echo "Doing things!" $(date +%D' '%T)

mkdir -p ${OUT_dir}
cd ${OUT_dir}

for i in $(seq 2 3)
do
	call_assoc="angsd -yBin ${YBIN} \
	-bam ${BAMLIST} \
	-model ${i} \
	-doAsso 1 \
	-GL 1 \
	-doMajorMinor 1 \
	-doMaf 1 \
	-SNP_pval 1e-6 \
    -Pvalue 1 \
	-out assoc_model${i}_pval_${PROJ}"
	echo ${call_assoc}
	eval ${call_assoc}
	echo ""
done

echo "Association tests are completed" $(date +%D' '%T)

cat EOT << readme >> ${OUT_dir}/README
This directory contains the following:
	assoc_model?__${PROJ}.lrt  ==  tab separated plain text files output from association analysis on files in ${BAMLIST}
		Chromosome	Position	Major	Minor	Frequency	N*	LRT	beta^	SE^	highHe*	highHo*	emIter~
readme

