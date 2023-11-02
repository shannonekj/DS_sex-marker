#!/bin/bash -l
#SBATCH -J mkMvcf
#SBATCH -e slurm/04.make_vcf_M_reference.j%j.err
#SBATCH -o slurm/04.make_vcf_M_reference.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=16:00:00
#SBATCH --mem=32G

set -e
set -v

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"
module load bio

###############
###  SETUP  ###
###############
proj="DS_sex-marker"
sex="M"

# directories
data_dir="/group/millermrgrp2/shannon/projects/${proj}"
bam_dir="${data_dir}/00-alignments_${sex}"
out_dir="${data_dir}/01-association_plink_${sex}_reference"

# files
	# make bamlist
echo $(date +%D' '%T) "Making bamlist"
[[ -d ${out_dir} ]] || mkdir -p ${out_dir}
cd ${bam_dir}
ls -al ${bam_dir}/*.sort-n.fixmate-m.sort.markdup-r.bam | awk '{print $9}' >> ${out_dir}/bamlist
bamlist="${out_dir}/bamlist"
echo "  Done! Bamlist at ${bamlist}"


#############
###  RUN  ###
#############
cd ${out_dir}
# Call genotypes & put into VCF
echo $(date +%D' '%T) "Calling genotypes"
call="angsd -bam ${bamlist} \
    -dovcf 1 \
    -gl 1 \
    -dopost 1 \
    -domajorminor 1 \
    -domaf 1 \
    -snp_pval 1e-6 \
    -out plink_${sex}_reference"
echo ${call}
eval ${call}
echo "  Done!"
echo ""



end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
