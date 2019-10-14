#!/bin/bash -l

# This script will identify loci and count the number of polymorphic sites in a RAD de novo assembly.
##  BEFORE RUNNING
#	Modify IdentifyLoci3.${PREFIX}.pl script to standards for the current RAD assembly

set -e 
set -v 


###############
###  SETUP  ###
###############
echo "Setting up variables"
echo ""

# external
DATA_dir=$1     # directory where novo scripts are located
SCRIPT_dir=$2	# directory with project scripts 
CODE_dir=$3	# directory with perl scripts
PREFIX=$4	# prefix of project

echo "Data directory: ${DATA_dir}"
echo "Script directory: ${SCRIPT_dir}"
echo "Code directory: ${CODE_dir}"
echo "Prefix: ${PREFIX}"
echo ""



###################
###  DO THINGS  ###
###################
##  identify & count loci
cd ${DATA_dir}

# Identify loci
echo "identifying loci -- $(date +%D' '%T)"
perl ${SCRIPT_dir}/IdentifyLoci3.${PREFIX}.pl ${PREFIX}.novo > ${PREFIX}.loci
chmod a=r ${PREFIX}.loci

# Then count polymorphic sites
echo "counting polymorphic sites -- $(date +%D' '%T)"
perl ${CODE_dir}/SimplifyLoci2.pl ${PREFIX}.loci > ${PREFIX}.simple.loci
nLoci=$(grep "_2" ${PREFIX}.simple.loci | wc -l)
echo "    There are ${nLoci} polymorphic sites." 
chmod a=r ${PREFIX}.simple.loci

