#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J qualFILT
#SBATCH -e 07_quality_filter.%j.err
#SBATCH -o 07_quality_filter.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=2-20:00:00

set -e 
set -v 

##  VARIABLES  ##
# directories
script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"
data_dir="/home/sejoslin/projects/sexMarker/data"
out_dir="${data_dir}/RAD_deNovo_maleOnly"

# other
prefix="SexMarker"
n="4"


##  RUN  ##
bash ${script_dir}/findBestInd.sh ${data_dir} ${out_dir} ${prefix} ${n}







# run script with
#	sbatch --mem MaxMemPerNode 07_quality_filter.sh

## Only run this script on the 5-10 best individuals <- found in /home/sejoslin/projects/DS_history/dataline_count.all.sorted

########################
### Best Individuals ###
########################

	# found in /home/sejoslin/projects/DS_history/data/id_loci/best_individuals.txt
	# example file name Ht08-87_2004_G11_R2.fastq

##############
### Script ###
##############

out_dir="/home/sejoslin/projects/DS_history/data/id_loci"
code_dir="/home/sejoslin/projects/DS_history/code"
in_dir="/home/sejoslin/projects/DS_history/data"

F1="/home/sejoslin/projects/DS_history/data/id_loci/best_individuals.txt"
n=$(wc -l $F1 | awk '{print $1}')

echo "Navigating to" ${out_dir}
cd ${out_dir}

## Grab best individuals

echo "Creating sym links for" ${n} "individuals"
x=1
while [ $x -le $n ]
do
        string="sed -n ${x}p $F1"
        str=$($string)
        var=$(echo $str | awk -F" " '{print $2}')
        bar=$(echo $str | awk -F" " '{print $4}')
	batch=$(echo $str | awk -F" " '{print $3}')
	set -- $var
	ln -s ${in_dir}/${batch}/${bar}/${var} ${var}
	x=$(( $x + 1 ))
done

## Filter, Hash and view occurences vs sequences

cd ${out_dir}
mkdir L80P80
mkdir hashes
mkdir sum_stats
mkdir raw

for i in Ht*_R1.fastq
do
	qual=$(basename $i _R1.fastq)
	echo "Starting" ${i}
	date

	echo "Quality filtering" ${qual}
	perl ${code_dir}/QualityFilter.pl ${i} > ${qual}_L80P80.fastq
	head -2 ${qual}_L80P80.fastq
	date

	echo "Shrinking" ${qual}
	perl ${code_dir}/HashSeqs.pl ${qual}_L80P80.fastq ${qual}  > ${qual}_L80P80.hash
	head -2 ${qual}_L80P80.hash
	date
	
	echo "Creating histogram for data in" ${qual}
	perl ${code_dir}/PrintHashHisto.pl ${qual}_L80P80.hash > ${qual}_L80P80.txt
	date
	
	echo "Finished with" ${i}
done

# clean up
mv *_L80P80.fastq L80P80/.
mv *.hash hashes/.
mv *_L80P80.txt sum_stats/.
mv *.fastq raw/.

cd hashes
cat *.hash > DS_history.fasta
