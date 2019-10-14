#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J novo
#SBATCH -e 09_id_loci.%j.err
#SBATCH -o 09_id_loci.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution

# run script with
#       sbatch --mem=32G 09_id_loci.sh

# set up directories
code_dir="/home/sejoslin/projects/DS_history/code"
data_dir="/home/sejoslin/projects/DS_history/data/id_loci"
tag="DS_history"

cd $data_dir

## Identify loci
echo "identifying loci"
date
perl ${code_dir}/IdentifyLoci3.pl ${tag}.novo > ${tag}.loci
chmod a=r ${tag}.loci

# Then count polymorphic sites
echo "counting polymorphic sites"
date
perl ${code_dir}/SimplifyLoci2.pl ${tag}.loci > ${tag}.simple.loci
grep "_2" ${tag}.simple.loci | wc -l
date
chmod a=r ${tag}.simple.loci
