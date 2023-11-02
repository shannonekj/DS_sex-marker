#!/bin/bash -l
#SBATCH -J dpth_F
#SBATCH -e slurm/j%j.get_depths_F_reference.err
#SBATCH -o slurm/j%j.get_depths_F_reference.out
#SBATCH -p high 
#SBATCH -c 20
#SBATCH --time=222:22:22
#SBATCH --mem=32G

###############
###  SETUP  ###
###############
# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh
conda activate samtools

# fail on weird errors
set -o nounset
set -o errexit
set -x

# variables
## directories
bam_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-alignments_F"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-depths_F_reference"
## files
reference="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/03-assemblies/sandbox_ipa_F/Hyp_tra_F_combined_chromonomer/output/CHRR_integrated.fa"
## other
bam_suffix=".sort-n.fixmate-m.sort.markdup-r.bam"

###################
###  DO THINGS  ###
###################

[[ -d ${out_dir} ]] || mkdir -p ${out_dir}
cd ${out_dir}

# symlink reference
ref_short=$(echo ${reference} | rev | cut -d/ -f1 | rev)
ln -s ${reference} ${ref_short}
samtools faidx ${ref_short}

# make list bam files for each sex
ls -l ${bam_dir}/*_F_*${bam_suffix} | awk '{print $9}' >> F.bamlist
ls -l ${bam_dir}/*_M_*${bam_suffix} | awk '{print $9}' >> M.bamlist

# make BED file of all loci
awk 'BEGIN {FS="\t"}; {print $1 FS "0" FS $2}' ${ref_short}.fai >> ${ref_short}.bed
# make list of loci
grep ">" ${ref_short} >> ${out_dir}/loci.list

for i in *.bamlist
do
    # pull out M or F
    sex=$(echo ${i} | cut -d. -f1)
    # get depths
    samtools depth -aa -b ${ref_short}.bed -f ${sex}.bamlist -o ${sex}.depth
done



