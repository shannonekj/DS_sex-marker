#!/bin/bash -l
#SBATCH -J sexAssoM
#SBATCH -e slurm/j%j.run_sexAssoc_M_reference_LRT.err
#SBATCH -o slurm/j%j.run_sexAssoc_M_reference_LRT.out
#SBATCH -n 20
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
sex="M"

# directories
script_dir="/home/sejoslin/git_repos/${proj}/scripts"
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker"
bam_dir="${data_dir}/00-alignments_${sex}"
out_dir="${data_dir}/01-association_${sex}_reference_genotypes"

# files
	# make bam
[[ -d ${out_dir} ]] || mkdir -p ${out_dir}
cd ${bam_dir}
ls -al ${bam_dir}/*.sort-n.fixmate-m.sort.markdup-r.bam | awk '{print $9}' >> ${out_dir}/bamlist
bamlist="${out_dir}/bamlist"
ybin="/home/sejoslin/git_repos/${proj}/metadata/DS_sex-marker.pheno.ybin"

threads=${SLURM_NTASKS}



#############
###  RUN  ###
#############

bash ${script_dir}/doAssoc_LRT_w_geno.sh ${out_dir} ${bamlist} ${proj} ${ybin} ${threads}



end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
