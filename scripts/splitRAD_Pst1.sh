#!/bin/bash
#
# NOTE : This script will split plates and barcodes for RAD sequencing data.
## Restriction Enzyme: Pst1 


###############
###  SETUP  ###
###############

# external variables
PROJ=$1
BARCODE=$2
DATA_DIR=$3
SCRIPT_DIR=$4

echo Project : ${PROJ}
echo Barcode : ${BARCODE}
echo Data directory : ${DATA_DIR}
echo Master scripts directory : ${SCRIPT_DIR}
echo ""




pop="sexMarker"

# directories
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
script_dir="/home/sejoslin/scripts"

#######################
### Set Up Barcodes ###
#######################

cd $data_dir

for i in BMAG0??
do
if [[ $i == "BMAG051" ]]
then
	barcode="CCGTCC"
	else
		echo $i "does not match given datasets!"
		fi
cd $i

###################
### Split Lanes ###
###################

## split lanes based on index read
$script_dir/BarcodeSplitList3Files.pl ${i}_*_R1_001.fastq ${i}_*_R2_001.fastq ${i}_*_R3_001.fastq $barcode $i
chmod a=r *.fastq

###################
### Split wells ###
###################

# get list of index bcs
ls ${i}_R3_??????.fastq | sed 's/.*R3_//g' | sed 's/.fastq//g' > indexid.list
head indexid.list

# split each lane by wells via inline bc
wc=$(wc -l indexid.list | awk '{print $1}') # number of lines
echo "There are" $wc "barcodes to split for" $i
x=1

while [ $x -le $wc ]
do
string="sed -n ${x}p indexid.list"
str=$($string)
var=$(echo $str | awk -Ft '{print $1}')
set -- $var
c1=$1
	echo "creating script to split by" $c1
	echo "#!/bin/bash" > 04_split_wells.${i}.${c1}.sh
	echo "#SBATCH --mail-user=sejoslin@ucdavis.edu" >> 04_split_wells.${i}.${c1}.sh
	echo "#SBATCH --mail-type=ALL" >> 04_split_wells.${i}.${c1}.sh
	echo "#SBATCH -J ${c1}.${i}" >> 04_split_wells.${i}.${c1}.sh
	echo "#SBATCH -e 04_split_wells.${i}.${c1}.%j.err" >> 04_split_wells.${i}.${c1}.sh
	echo "#SBATCH -o 04_split_wells.${i}.${c1}.%j.out" >> 04_split_wells.${i}.${c1}.sh
	echo "#SBATCH -c 20" >> 04_split_wells.${i}.${c1}.sh
	echo "#SBATCH -p high" >> 04_split_wells.${i}.${c1}.sh
	echo "#SBATCH --time=1-20:00:00" >> 04_split_wells.${i}.${c1}.sh
	echo "" >> 04_split_wells.${i}.${c1}.sh
	echo "set -e # exits upon failing command" >> 04_split_wells.${i}.${c1}.sh
	echo "set -v # verbose -- all lines" >> 04_split_wells.${i}.${c1}.sh
	echo "set -x # trace of all commands after expansion before execution" >> 04_split_wells.${i}.${c1}.sh
	echo "" >> 04_split_wells.${i}.${c1}.sh
	echo "# This script is run from ${code_dir}/03_split_RAD.all.sh" >> 04_split_wells.${i}.${c1}.sh
	echo "# You may need modifications to run it alone." >> 04_split_wells.${i}.${c1}.sh
	echo "" >> 04_split_wells.${i}.${c1}.sh
	echo "cd ${data_dir}/${i}" >> 04_split_wells.${i}.${c1}.sh
	echo "" >> 04_split_wells.${i}.${c1}.sh
	#echo "#for file in BMAG04?_*R1_??????.fastq" >> 04_split_wells.${i}.${c1}.sh
	#echo "#do" >> 04_split_wells.${i}.${c1}.sh
	echo "##  put all the same lane in a directory" >> 04_split_wells.${i}.${c1}.sh
	echo "mkdir -p ${c1}" >> 04_split_wells.${i}.${c1}.sh
	echo "mv *_${c1}.fastq ${c1}/." >> 04_split_wells.${i}.${c1}.sh
	echo "cd ${c1}" >> 04_split_wells.${i}.${c1}.sh
	echo "" >> 04_split_wells.${i}.${c1}.sh
        echo "$script_dir/BCsplitBestRadPE2.pl ${i}_R1_${c1}.fastq ${i}_R3_${c1}.fastq GGCAGATCTGTGCAG,GGATGCCTAATGCAG,GGAACGAACGTGCAG,GGAGTACAAGTGCAG,GGCATCAAGTTGCAG,GGAGTGGTCATGCAG,GGACAGCAGATGCAG,GGACCTCCAATGCAG,GGACGCTCGATGCAG,GGACGTATCATGCAG,GGACTATGCATGCAG,GGAGAGTCAATGCAG,GGCAAGACTATGCAG,GGCAATGGAATGCAG,GGCACTTCGATGCAG,GGCAGCGTTATGCAG,GGCATACCAATGCAG,GGCCAGTTCATGCAG,GGCTCAATGATGCAG,GGCTGAGCCATGCAG,GGCTGGCATATGCAG,GGGAATCTGATGCAG,GGGACTAGTATGCAG,GGGAGCTGAATGCAG,GGGGTGCGAATGCAG,GGGTACGCAATGCAG,GGGTCGTAGATGCAG,GGGTCTGTCATGCAG,GGGTGTTCTATGCAG,GGTAGGATGATGCAG,GGTGGTGGTATGCAG,GGTTCACGCATGCAG,GGACACGAGATGCAG,GGAAGAGATCTGCAG,GGAAGGACACTGCAG,GGAATCCGTCTGCAG,GGAGGCTAACTGCAG,GGATAGCGACTGCAG,GGACGACAAGTGCAG,GGATTGGCTCTGCAG,GGCAAGGAGCTGCAG,GGCACCTTACTGCAG,GGCTAAGGTCTGCAG,GGGAACAGGCTGCAG,GGGACAGTGCTGCAG,GGGAGTTAGCTGCAG,GGGATGAATCTGCAG,GGGCCAAGACTGCAG ${i}_${c1}" >> 04_split_wells.${i}.${c1}.sh
	echo "#chmod a=r *.fastq" >> 04_split_wells.${i}.${c1}.sh

echo "done creating script for" ${c1}
echo "Submitting job for 04_split_wells.${i}.${c1}.sh"
sbatch --mem MaxMemPerNode 04_split_wells.${i}.${c1}.sh
x=$(( $x + 1 ))
done

cd  $data_dir
done
