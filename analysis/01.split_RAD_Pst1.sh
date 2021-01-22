#!/bin/bash
#SBATCH -J spltALL
#SBATCH -e slurm/j%j.split_RAD_Pst1.err
#SBATCH -o slurm/j%j.split_RAD_Pst1.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --mem=32G
#SBATCH --time=5-20:00:00

## NOTE: ## This project uses the LAST 48 wells on a plate--adjust barcodes accordingly.

# run script with
# NOW       sbatch <script>
# FUTURE    bash split_RAD_Pst1.sh <glbl/pth/to/data_directory> <glbl/pth/to/script_dir> <library_prefix> <restriction_enzyme>

###############
###  SETUP  ###
###############
# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh
conda activate perl

# fail on weird errors
set -o nounset
set -o errexit
set -x

# variables
## directories
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-raw_data" # directory that contains directories with raw sequence data from a lane in each (e.g. ${data_dir}/BMAG043/sequence_R?.fastq)
script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"

## independent
re="Pst1"

# downloads 
## split scripts
[ -d ${script_dir} ] || mkdir -p ${script_dir}
cd ${script_dir}
[ -f BarcodeSplitList3Files.pl ] || wget https://raw.githubusercontent.com/shannonekj/ngs_scripts/master/BarcodeSplitList3Files.pl
[ -f BCsplitBestRadPE2.pl ] || wget https://raw.githubusercontent.com/shannonekj/ngs_scripts/master/BCsplitBestRadPE2.pl
## list of barcodes based on RE
[ -f barcodes_${re}.csv ] || wget https://raw.githubusercontent.com/shannonekj/ngs_scripts/master/barcodes_${re}.csv
chmod 755 BarcodeSplitList3Files.pl
chmod 755 BCsplitBestRadPE2.pl 


#############
###  RUN  ###
#############
# set up barcodes
cd ${data_dir}
for i in BMAG0??                ### CHANGE ###
do
if [[ $i == "BMAG051" ]]        ### CHANGE ###
then
	barcode="CCGTCC"            ### CHANGE ###
	else
		echo $i "does not match given datasets!"
		fi
    cd $i
    # split lanes
    ## split lanes based on index read
    ${script_dir}/BarcodeSplitList3Files.pl ${i}_*_R1_001.fastq ${i}_*_R2_001.fastq ${i}_*_R3_001.fastq $barcode $i
    chmod a=r *.fastq

    # split wells
    ## get list of index bcs
    ls ${i}_R3_??????.fastq | sed 's/.*R3_//g' | sed 's/.fastq//g' > indexid.list
head indexid.list

    ## split each lane by wells via inline bc
    wc=$(wc -l indexid.list | awk '{print $1}') # number of lines
    echo "There are" $wc "barcodes to split for" $i
    x=1

    ## make bash script to pull out sequences tied to each barcode
    while [ $x -le $wc ]
    do
        string="sed -n ${x}p indexid.list"
        str=$($string)
        var=$(echo $str | awk -Ft '{print $1}')
        set -- $var
        c1=$1
	    echo "creating script to split by" $c1
	    echo "#!/bin/bash" > split_wells_${re}.${i}.${c1}.sh
	    echo "#SBATCH --mail-user=sejoslin@ucdavis.edu" >> split_wells_${re}.${i}.${c1}.sh
	    echo "#SBATCH --mail-type=ALL" >> split_wells_${re}.${i}.${c1}.sh
	    echo "#SBATCH -J ${c1}.${i}" >> split_wells_${re}.${i}.${c1}.sh
	    echo "#SBATCH -e split_wells_${re}.${i}.${c1}.%j.err" >> split_wells_${re}.${i}.${c1}.sh
	    echo "#SBATCH -o split_wells_${re}.${i}.${c1}.%j.out" >> split_wells_${re}.${i}.${c1}.sh
	    echo "#SBATCH -c 20" >> split_wells_${re}.${i}.${c1}.sh
	    echo "#SBATCH -p high" >> split_wells_${re}.${i}.${c1}.sh
	    echo "#SBATCH --time=1-20:00:00" >> split_wells_${re}.${i}.${c1}.sh
	    echo "" >> split_wells_${re}.${i}.${c1}.sh
	    echo "set -e # exits upon failing command" >> split_wells_${re}.${i}.${c1}.sh
	    echo "set -v # verbose -- all lines" >> split_wells_${re}.${i}.${c1}.sh
	    echo "set -x # trace of all commands after expansion before execution" >> split_wells_${re}.${i}.${c1}.sh
	    echo "" >> split_wells_${re}.${i}.${c1}.sh
	    echo "# You may need modifications to run this script alone." >> split_wells_${re}.${i}.${c1}.sh
	    echo "" >> split_wells_${re}.${i}.${c1}.sh
	    echo "cd ${data_dir}/${i}" >> split_wells_${re}.${i}.${c1}.sh
	    echo "" >> split_wells_${re}.${i}.${c1}.sh
	    #echo "#for file in BMAG04?_*R1_??????.fastq" >> split_wells_${re}.${i}.${c1}.sh
	    #echo "#do" >> split_wells_${re}.${i}.${c1}.sh
	    echo "##  put all the same lane in a directory" >> split_wells_${re}.${i}.${c1}.sh
	    echo "mkdir -p ${c1}" >> split_wells_${re}.${i}.${c1}.sh
	    echo "mv *_${c1}.fastq ${c1}/." >> split_wells_${re}.${i}.${c1}.sh
	    echo "cd ${c1}" >> split_wells_${re}.${i}.${c1}.sh
	    echo "" >> split_wells_${re}.${i}.${c1}.sh
        echo "${script_dir}/BCsplitBestRadPE2.pl ${i}_R1_${c1}.fastq ${i}_R3_${c1}.fastq $(cat ${script_dir}/barcodes_${re}.csv) ${i}_${c1}" >> split_wells_${re}.${i}.${c1}.sh 
	    echo "#chmod a=r *.fastq" >> split_wells_${re}.${i}.${c1}.sh

        echo "done creating script for" ${c1}
        echo "Submitting job for split_wells_${re}.${i}.${c1}.sh"
        sbatch --mem MaxMemPerNode split_wells_${re}.${i}.${c1}.sh
        x=$(( $x + 1 ))
    done
    cd  ${data_dir}
done
