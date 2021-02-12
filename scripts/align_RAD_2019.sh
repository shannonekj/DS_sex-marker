#!/bin/bash -l

# This script will align a list of files to a reference genome
## Downloaded from https://raw.githubusercontent.com/shannonekj/ngs_scripts/master/align_RAD_2019.sh

###############
###  SETUP  ###
###############
list=$1		# A list of all individuals to align (FMT: R1 | R2 | prefix)
ref=$2		# Path to reference genome
out=$3		# Outout directory

echo List : ${list}
echo Reference Genome : ${ref}
echo Output Directory : ${out}

# make index for reference genome
## get shortened name
ref_short=$(echo ${ref} | rev | cut -f1 -d/ | rev)
## make symbolic link to reference genome
[ -d ${out}/ref_genome ] || mkdir -p ${out}/ref_genome
cd ${out}/ref_genome
[ -h ${ref_short} ] || ln -s ${ref} ${ref_short}
## index reference genome
[ -f ${ref_short}.sa ] || bwa index ${ref_short}; sleep 1m


# create run script for each individual
cd ${out}
wc=$(wc -l ${list} | awk '{print $1}')
x=1
while [ $x -le $wc ] 
do
	echo "Starting ${x} of ${wc}"
	string="sed -n ${x}p ${list}" 
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1, $2, $3}')   
	set -- $var
	c1=$1
	c2=$2
	c3=$3

	cat << ALIGN >> ${out}/${c3}.sh
#!/bin/bash -l
#
#SBATCH -e ${c3}.j%j.err
#SBATCH -o ${c3}.j%j.out
#SBATCH -t 08:00:00
#SBATCH -p med
#SBATCH --mem=8G

echo $(date +%D' '%T)  Now aligning ${c3}
bwa mem ${out}/ref_genome/${ref_short} ${c1} ${c2} | samtools view -Sb - | samtools sort -n - | samtools fixmate -m - ${out}/${c3}.sort-n.fixmate-m.bam
echo Complete!
echo ""

echo $(date +%D' '%T)  Sorting and removing duplicates for individual ${c3}
samtools sort ${out}/${c3}.sort-n.fixmate-m.bam | samtools markdup -r - ${out}/${c3}.sort-n.fixmate-m.sort.markdup-r.bam
echo Complete! 
echo ""

echo $(date +%D' '%T)  Indexing bam file
samtools index ${out}/${c3}.sort-n.fixmate-m.sort.markdup-r.bam
echo Complete!
echo ""
ALIGN

	sbatch ${out}/${c3}.sh
	echo "Submitted ${c3}.sh"
	echo ""
	x=$(( $x + 1 ))
done

cat << readme >> ${out}/README
This directory contains:
	list == A list of sequence files to be aligned to ${ref}
	*.sort-n.fixmate-m.bam == aligned, sorted and fixmated bams
	*.sort-n.fixmate-m.sort.markdup-r.bam == aligned, sorted, fixmated and markdup bams
	*.sort-n.fixmate-m.sort.markdup-r.bam.bai == indexed bam file
    *.sh == alignment script for each individual
readme

