#!/bin/bash -l

#	This script will call genotypes.
# 	Neccessary file(s):
#       * bamlist == list of bam files
#   NOTE: Need to have conda environment "ANGSD" with angsd installed

# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate conda env
conda activate ANGSD

# fail on weird errors
set -o nounset
set -o errexit
set -x
set -e



###############
###  SETUP  ###
###############

angsd -version # this doesn't actually print a version number in one line but rather prints an error that contains the version number in it

echo "Setting up variables" $(date +%D' '%T)
# external
OUT_DIR=$1	# directory where output will be written to
BAMLIST=$2	# list of bamfiles (global path)
PREFIX=$3   # project descriptor
THREADS=$4  # n threads used

# internal
nInd=$(wc -l ${BAMLIST} | awk '{print $1}')
mInd=$((${nInd}/2))

###################
###  DO THINGS  ###
###################

echo "Doing things!" $(date +%D' '%T)

[ - d ${OUT_DIR} ] || mkdir -p ${OUT_DIR}
cd ${OUT_DIR}

call_geno="angsd \
    -bam ${BAMLIST} \
    -GL 1 \
    -doGeno 5 \
    -doPost 1 \
    -doMaf 2 \
    -doMajorMinor 1 \
    -minInd ${mInd} \
    -minMapQ 20 \
    -minQ 20 \
    -postCutoff 0.85 \
    -minMaf 0.05 \
    -SNP_pval 1e-6 \
    -nThreads ${THREADS} \
    -out ${PREFIX}
"

echo $call_geno
eval $call_geno

cat <<EOT >> README
This directory contains files related to calling genotypes with ANGSD.
Files:
    *.geno.gz == called genotypes FMT: CHR | POS | MAJOR | MINOR | GENO_IND_1...GENO_IND_N  
    *.mafs.gz == allele frequencies FMT: CHR | POS | MAJOR | MINOR | FREQ | PHAT | N_IND
EOT
