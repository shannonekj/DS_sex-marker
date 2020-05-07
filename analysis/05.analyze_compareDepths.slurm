#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J compM2F
#SBATCH -e slurm/05.analyze_compareDepths.j%j.err
#SBATCH -o slurm/05.analyze_compareDepths.j%j.out
#SBATCH -p high
#SBATCH -c 20
#SBATCH --time=02-02:22:22
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

# directories
ana_dir="/group/millermrgrp2/shannon/projects/${proj}/03-depth_Analysis"



###################
###  DO THINGS  ###
###################
# Grab each of the depths for females and males
cd ${ana_dir}
echo "Counting depths in male and females"
echo ""
x=1
n=$(wc -l ${proj}.depth | awk '{print $1}')
while [ $x -le $n ]
do
	echo "Processing line ${x}/${n}."
	z=0
	b=0
	locus=$(sed -n "${x}p" ${proj}.depth | awk '{print $1}')
	for i in $(seq 3 26)
	do
		y=$(sed -n "${x}p" ${proj}.depth | awk "{print \$${i}}")
		z=$(( $z + $y ))
	done
	echo "    Females counts complete!"
	for j in $(seq 27 50)
	do
		a=$(sed -n "${x}p" ${proj}.depth | awk "{print \$${i}}")
		b=$(( $a + $b ))
	done
	echo "    Male counts complete!"
	echo -e "${locus}\t${z}\t${b}" >> ${proj}.counts
	x=$(( $x + 1 ))
done
echo ""

## Sort
echo "Sorting depth counts"
sort -n -k3,3 ${proj}.counts >> ${proj}.counts.sorted
echo "    Complete!"

end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
