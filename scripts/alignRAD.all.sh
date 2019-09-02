#!/bin/bash -l

#	This script will align fastq files to a reference assembly.

set -e
set -v


###############
###  SETUP  ###
###############

echo "Setting up variables" 

# external
DATA_dir=$1	# directory where fasta data are contained
RAD_dir=$2	# RAD alignment directory
LIB_prefix=$3	# prefix to of where fasta data are located
FQ_prefix=$4	# fastq file prefix 
PROJ=$5		# project ID 
REFERENCE=$6	# reference fasta

###################
###  DO THINGS  ###
###################

mkdir -p ${RAD_dir}
echo "This directory contains the following:" >> ${RAD_dir}/README

### Make list of all sequence files to be aligned
cd ${DATA_dir}

for i in ${LIB_prefix}??
do
	echo "Navigating to ${i}"
	cd ${i}
	wc=$(wc -l indexid.list | awk '{print $1}')
	x=1
	while [ $x -le $wc ]
	do
		tagline="sed -n ${x}p indexid.list"
		tag=$($tagline)
		echo $tag
		cd ${tag}
		for file in ${FQ_prefix}*_R1.fastq
		do
			base=$(basename $file _R1.fastq)
			echo ${base} ${DATA_dir}/${i}/${tag}/${base} >> ${RAD_dir}/${PROJ}.RADseqID.list
			# RADseqID.list fmt: ind_ID global/path/to/ind
		done
		cd ${DATA_dir}/${i}
		x=$(( $x + 1 ))
	done
	cd ${DATA_dir}
done
echo "    ${PROJ}.RADseqID.list == list of individuals to align (fmt: ind_ID global/path/to/ind)" >> ${RAD_dir}/README

### Index reference
bwa index ${REFERENCE}
sleep 1m

### Align to reference
cd ${RAD_dir}
wc=$(wc -l ${PROJ}.RADseqID.list | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
	string="sed -n ${x}p ${PROJ}.RADseqID.list"
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')
        set -- $var
        c1=$1
        c2=$2

	cat << ALIGNING >> align_${c1}.sh
#!/bin/bash -l
#
#SBATCH -o align_${c1}.j%j.out
#SBATCH -e align_${c1}.j%j.err
#SBATCH --mem=32G
#SBATCH -t 03:00:00
#SBATCH -J ${c1}

set -e
set -v

hostname
start=\`date +%s\`
echo "My SLURM_JOB_ID: \$SLURM_JOB_ID"

echo "Aligning reads \$(date)"
bwa mem ${REFERENCE} ${c2}_R1.fastq ${c2}_R2.fastq | samtools view -Sb - | samtools sort - -o ${c1}.sort.bam

echo "Pairing reads \$(date)"
samtools view -f 0x2 -b ${c1}.sort.bam > ${c1}.sort.proper.bam

echo "Removing duplicate reads \$(date)"
samtools rmdup ${c1}.sort.proper.bam ${c1}.sort.proper.rmdup.bam

sleep 2m
echo "Indexing alignment \$(date)"
samtools index ${c1}.sort.proper.rmdup.bam ${c1}.sort.proper.rmdup.bam.bai

## STATS ##
reads=\$(samtools view -c ${c1}.sort.bam)
ppalign=\$(samtools view -c ${c1}.sort.proper.bam)
rmdup=\$(samtools view -c ${c1}.sort.proper.rmdup.bam)
echo \"${c1},\${reads},\${ppalign},\${rmdup}\" > ${c1}.stats

echo "All statistics have been printed to ${c1}.stats in the following order: aligned reads, aligned properly paired reads, and aligned reads with duplicates removed."
echo "Job complete at \$(date)"

end=\`date +%s\`
runtime=\$((end-start))
echo "Runtime : "\${runtime}
ALIGNING

	sbatch align_${c1}.sh
	x=$(( $x + 1 ))
done

###  README  ###
cat << readme >> ${RAD_dir}/README
    *.sort == all sorted aligned reads
    *.sort.proper.bam == all sorted & properly paired aligned reads
    *.sort.proper.rmdup.bam == sorted & properly paired reads with duplicates removed 
    *sort.proper.rmdup.bam.bai == indexed alignment
    *.stats == fmt: (all aligned reads) (all aligned & properly paired reads) (aligned, properly paired reads with duplicated removed)
readme
