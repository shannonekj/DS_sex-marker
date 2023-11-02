#!/bin/bash -l
#SBATCH -J sexAssoc
#SBATCH -e slurm/j%j.run_sexAssoc_F_reference_LRT.additive.err
#SBATCH -o slurm/j%j.run_sexAssoc_F_reference_LRT.additive.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=16:00:00
#SBATCH --mem=32G

set -e
set -v

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"

###############
###  SETUP  ###
###############
proj="DS_sex-marker"
sex="F"

# directories
script_dir="/home/sejoslin/git_repos/${proj}/scripts"
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker"
bam_dir="${data_dir}/00-alignments_${sex}"
out_dir="${data_dir}/01-association_${sex}_reference"

# files
	# make bam
[[ -d ${out_dir} ]] || mkdir -p ${out_dir}
#cd ${bam_dir}
#ls -al ${bam_dir}/*.sort-n.fixmate-m.sort.markdup-r.bam | awk '{print $9}' >> ${out_dir}/bamlist
bamlist="${out_dir}/bamlist"
ybin="/home/sejoslin/git_repos/${proj}/metadata/DS_sex-marker.pheno.ybin"

echo "Setting up modules" $(date +%D' '%T)
module load bio
angsd -version # this doesn't actually print a version number in one line but rather prints an error that contains the version number in it


#############
###  RUN  ###
#############
cd ${out_dir}
echo $(date +%D' '%T) " -- Running association in ANGSD"
call="angsd -yBin ${ybin} \
    -bam ${bamlist} \
    -model 1 \
    -doAsso 1 \
    -GL 1 \
    -doMajorMinor 1 \
    -doMaf 1 \
    -SNP_pval 1e-6 \
    -out assoc_model1_LRT_${proj}"
echo ${call}
eval ${call}
echo "  Done!"
echo ""

end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
