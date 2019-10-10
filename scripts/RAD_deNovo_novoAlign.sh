#!/bin/bash -l

# This script will index and align RAD-seq reads using the software novoAlign 

set -e 
set -v 

###############
###  SETUP  ###
###############
echo "Setting up variables"

# external
DATA_dir=$1     # directory where raw split fastq files are located
PREFIX=$2       # prefix of project

echo "Data directory: ${DATA_dir}"
echo "Prefix: ${PREFIX}"
echo ""



###################
###  DO THINGS  ###
###################
cd ${DATA_dir}

## index ##
echo "Indexing fasta files $(date +%D' '%T)"
novoindex ${PREFIX}.fa.index ${PREFIX}.fasta
chmod a=r ${PREFIX}.fa.index
echo "    Done!"

## align ##
echo "Aligning reads $(date +%D' '%T)"
novoalign  -r E 48 -t 180 -d ${PREFIX}.fa.index -f ${PREFIX}.fasta > ${PREFIX}.novo
chmod a=r ${PREFIX}.novo
echo "    Done!"
