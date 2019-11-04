#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J compDepF
#SBATCH -e 04.analyze_B_compareDepths.maleRef_1_relaxed.j%j.err
#SBATCH -o 04.analyze_B_compareDepths.maleRef_1_relaxed.j%j.out
#SBATCH -p high
#SBATCH -c 20
#SBATCH --time=03-02:22:22
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
ana_dir="/group/millermrgrp2/shannon/projects/${proj}/03-depth_Analysis_relaxed/maleRef"



###################
###  DO THINGS  ###
###################
# Grab each of the depths for females and males
cd ${ana_dir}
echo "Counting depths in male and females"
echo ""
echo -e "locus\tfemale_counts\tfemale_meanDepth\tmale_counts\tmale_meanDepth" > ${proj}.1.counts.sorted
x=1
n=$(wc -l ${proj}.depth | awk '{print $1}')
while [ $x -le $n ]
do
	echo "Processing line ${x}/${n}."
	z=0
	z_ct=0
	b=0
	b_ct=0
	locus=$(sed -n "${x}p" ${proj}.depth | awk '{print $1}')
	
	for i in $(seq 3 26)
	do
		# first grab depth of individual
		y=$(sed -n "${x}p" ${proj}.depth | awk "{print \$${i}}")
		if [ $y -gt 0 ]
		then
			# add to individual count
			z=$(( $z + 1 ))
			# add to total female depth
			z_ct=$(( $z_ct + $y ))
		elif [ $y -eq 0 ]
		then
			z=$z
		else
			echo "Read ${locus} ${y} doesnt make sense."
		fi
	done
	echo "    Females counts complete!"

	for j in $(seq 27 50)
	do
		a=$(sed -n "${x}p" ${proj}.depth | awk "{print \$${j}}")
		if [ $a -gt 0 ]
		then
			# add to individual count
			b=$(( $b + 1 ))
			# add to total female depth
			b_ct=$(( $b_ct + $a ))
		elif [ $a -eq 0 ]
		then
			b=$b
		else
			echo "Read ${locus} ${b} doesn't make sense."
		fi
	done
	echo "    Male counts complete!"

	# get mean count for marker
	z_mc=$(( $z_ct / $z ))
	b_mc=$(( $b_ct / $b ))
	# print to file
	echo -e "${locus}\t${z}\t${z_mc}\t${b}\t${b_mc}" >> ${proj}.1.counts
	x=$(( $x + 1 ))
done
echo ""

## Sort
echo "Sorting depth counts"
sort -n -k2,2 ${proj}.1.counts >> ${proj}.1.counts.sorted
echo "    Complete!"



end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
