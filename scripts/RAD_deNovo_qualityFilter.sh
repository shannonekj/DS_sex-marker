#!/bin/bash -l

# This script will quality filter and hash sequences for a selected group of individuals that we will create a denovo partial assembly for.

set -e # exits upon failing command
set -v # verbose -- all lines

###############
###  SETUP  ###
###############

echo "Setting up variables"

# external
DATA_dir=$1     # directory where raw split fastq files are located
OUT_dir=$2      # directory to direct output to
PREFIX=$3       # Prefix of project
BEST_file=$4            # number of individuals to select

# internal
sum_file="${OUT_dir}/${PREFIX}_line_count.all"

echo "Data directory: ${DATA_dir}"
echo "Output directory: ${OUT_dir}"
echo "Prefix: ${PREFIX}"
echo "Best Individual File: ${BEST_file}"
echo ""



###################
###  DO THINGS  ###
###################

