#!/bin/bash -l
#SBATCH -J mkPops
#SBATCH -e slurm/04b.make_pfile_4_plink.j%j.err
#SBATCH -o slurm/04b.make_pfile_4_plink.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=16:00:00
#SBATCH --mem=32G


## NEED IN THE FOLLOWING FORMAT
#FID	IID	dad	mom	sex	pheno	population
#2427	NA19919	NA19908	NA19909	1	0	ASW
#2431	NA19916	0	0	1	0	ASW
#2424	NA19835	0	0	2	0	ASW
#2469	NA20282	0	0	2	0	ASW
#2368	NA19703	0	0	1	0	ASW

### Since I don't have paternal and maternal information will need to use the following when running GWA test
# --no-parents flag

# female
## setup
sex="F"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-association_plink_${sex}_reference"
## do things
cd ${out_dir}
n=$(wc -l bamlist | awk '{print $1}')
echo -e "FID\tIID\tSEX\tPHENOTYPE" > phenolist
for i in $(seq 1 ${n})
do
    echo "  processing line ${i}"
    FID=$(sed -n ${i}p bamlist | rev | cut -d/ -f 1 | rev | cut -d_ -f 1-4)
    y=$(echo "${i}-1" | bc)
    IID="ind${y}"
    sex=$(echo $FID | cut -d_ -f3)
    if [ ${sex} = "F" ]; then SEX="2"; echo "${FID} is female"; else SEX="1"; echo ${FID} is male; fi
    echo -e "${FID}\t${IID}\t${SEX}\t${SEX}" >> phenolist
done


# male
sex="M"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-association_plink_${sex}_reference"
## do things
cd ${out_dir}
n=$(wc -l bamlist | awk '{print $1}')
echo -e "FID\tIID\tSEX\tPHENOTYPE" > phenolist
for i in $(seq 1 ${n})
do
    echo "  processing line ${i}"
    FID=$(sed -n ${i}p bamlist | rev | cut -d/ -f 1 | rev | cut -d_ -f 1-4)
    y=$(echo "${i}-1" | bc)
    IID="ind${y}"
    sex=$(echo $FID | cut -d_ -f3)
    if [ ${sex} = "F" ]; then SEX="2"; echo "${FID} is female"; else SEX="1"; echo ${FID} is male; fi
    echo -e "${FID}\t${IID}\t${SEX}\t${SEX}" >> phenolist
done
