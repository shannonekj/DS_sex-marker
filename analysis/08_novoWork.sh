#!/bin/bash
#BATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J novo
#SBATCH -e 08_novoWork.%j.err
#SBATCH -o 08_novoWork.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution

# run script with
#       sbatch --mem=32G 08_novoWork.sh

# set up directories
code_dir="/home/sejoslin/projects/DS_history/code"
data_dir="/home/sejoslin/projects/DS_history/data/id_loci"
tag="DS_history"

cd $data_dir

## make file with all hashes
cat hashes/*.hash > ${tag}.fasta
chmod a=r ${tag}.fasta

## index DS_history.fasta
novoindex ${tag}.fa.index ${tag}.fasta
chmod a=r ${tag}.fa.index

## align DS_history.fasta 
novoalign  -r E 48 -t 180 -d ${tag}.fa.index -f ${tag}.fasta > ${tag}.novo
chmod a=r ${tag}.novo
