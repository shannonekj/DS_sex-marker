#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J cmpFemRef
#SBATCH -e slurm/04.analyze_A_compareAlignments_femaleRef_relaxed.j%j.err
#SBATCH -o slurm/04.analyze_A_compareAlignments_femaleRef_relaxed.j%j.out
#SBATCH -p high
#SBATCH -c 20
#SBATCH --time=02:22:22
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
prefix="SexMarker_F_relaxed"

# directories
loci_dir="/group/millermrgrp2/shannon/projects/${proj}/01-RAD_deNovo_relaxed/femaleOnly"
bam_dir="/group/millermrgrp2/shannon/projects/${proj}/02-RAD_alignments_relaxed/femaleRef"
ana_dir="/group/millermrgrp2/shannon/projects/${proj}/03-depth_Analysis_relaxed/femaleRef"

# files
reference="${loci_dir}/${prefix}.simple._1.loci"

# other
bam_end="sort.bam"


###################
###  DO THINGS  ###
###################
mkdir -p ${ana_dir}

## Make list of loci
echo "Making a list of loci"
grep ">" ${reference} >> ${ana_dir}/loci.list

## Make BED file
echo "Creating BED file"
cd ${ana_dir}
x=1
n=$(wc -l loci.list | awk '{print $1}')
while [ $x -le $n ]
do
	loc=$(sed -n "${x}p" loci.list)
	echo "Processing read ${loc} ${x}/${n}"
	echo ${loc} 39 40 >> loci.bed
	x=$(( $x + 1 ))
done
sed -i 's/>//g' loci.bed
echo ""

## Make list of BAM files
echo "Making list of BAM files"
ls -alh ${bam_dir}/*_F_*.${bam_end} | awk '{print $9}' > ${proj}.bamlist
ls -alh ${bam_dir}/*_M_*.${bam_end} | awk '{print $9}' >> ${proj}.bamlist

## Get matrix of depths
echo "Running samtools"
samtools --version
samtools depth -a -b loci.bed -f ${proj}.bamlist > ${proj}.depth

echo "Finished!"



end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
