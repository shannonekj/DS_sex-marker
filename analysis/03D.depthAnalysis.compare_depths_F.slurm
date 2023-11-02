#!/bin/bash -l
#SBATCH -J cnt_F
#SBATCH -e slurm/j%j.compare_depths_F_reference.err
#SBATCH -o slurm/j%j.compare_depths_F_reference.out
#SBATCH -p high 
#SBATCH -c 20
#SBATCH --time=22:22:22
#SBATCH --mem=32G

###############
###  SETUP  ###
###############
set -x
set -v

# variables
## directories
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-depths_F_reference"
## files
depthfile="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-depths_F/CHRR_integrated.fa.depth"



###################
###  DO THINGS  ###
###################

if [ ! -d ${out_dir} ]
then
    echo "${out_dir} does not exist"
    exit 1
fi

cd ${out_dir}

for i in *.bamlist
do
    sex=$(echo ${i} | cut -d. -f1)
    depthfile="${sex}.depth"
    countfile="${sex}.counts"
    N=$(wc -l $i | awk '{print $1}')
    echo "Creating ${sex} counts file"
    echo -e "locus\t${sex}_counts\t${sex}_mean_depth" > ${countfile}
    echo "Counting ${sex} read depths for each locus"
    x=1
    n=$(wc -l ${depthfile} | awk '{print $1}')
    
    # go through each line of depth file and pull out counts
    while [ $x -le $n ]
    do
        echo "    Processing line ${x}/${n}"
        z=0
        z_ct=0
        locus=$(sed -n "${x}p" ${depthfile} | awk -v OFS='_' '{print $1, $2}')
        ncol=$(( $N + 2 ))

        # go through each column and total depths
        for col in $(seq 3 ${ncol})
        do
            # grab individual depth
            y=$(sed -n "${x}p" ${depthfile} | awk "{print \$${col}}")
            echo "        The depth of column ${col} is ${y}"
            if [ $y -gt 0 ]
            then
                # add depth to individual count
                z=$(( $z + 1 ))
                echo A total of $z ${sex} individuals have coverage.
                # add to total female depth
                z_ct=$(( $z_ct + $y ))
                echo Total ${sex} depth is $z_ct
            elif [ $y -eq 0 ]
            then
                z=$z
            else
                echo "Read ${locus} ${y} doesnt make sense."
            fi
            # get mean count for marker
            z_mc=0
            if [ ${z_mc} -gt 0 ]
            then
                z_mc=$(( $z_ct / $z ))
            fi
            # print to file
            echo -e "${locus}\t${z}\t${z_mc}" >> ${countfile}
        done
        x=$(( $x + 1 ))
    done
    echo "${sex} counts complete"
done

## now will have two file.... M.counts and F.counts

# combine M and F count files
## check to make sure number of rows match for M and F count files
malefile="M.counts"
femalefile="F.counts"
mrow=$(wc -l ${malefile} | awk '{print $1}')
echo "${malefile} has ${mrow} lines"
frow=$(wc -l ${femalefile} | awk '{print $1}')
echo "${femalefile} has ${frow} lines"

echo -e "locus\tfemale_counts\tfemale_meanDepth\tmale_counts\tmale_meanDepth" > all.sorted.counts

if [ $mrow -eq $frow ]
then
    ### MAKE MASTER COUNT FILE
    x=1
    n=$(wc -l F.counts | awk '{print $1}')
    while [ $x -le $n ]
    do
        # check if locus matches
        mlocus=$(sed -n "${x}p" ${malefile} | awk '{print $1}')
        flocus=$(sed -n "${x}p" ${femalefile} | awk '{print $1}')
        if [ $mlocus == $flocus ]
        then
            mcount=$(sed -n "${x}p" ${malefile} | awk -v OFS='\t' '{print $2, $3}')
            fcount=$(sed -n "${x}p" ${femalefile} | awk -v OFS='\t' '{print $2, $3}')
            echo -e "${mlocus}\t${fcount}\t${mcount}" >> all.counts
        else
            echo "Male locus ($mlocus) does not match female locus ($flocus) at line $x"
        fi
        x=$(( $x + 1 ))
    done
elif [ $mrow -gt $frow ]
then
    echo "Male count file has more lines than female count file."
    exit 1
elif [ $mrow -lt $frow ]
then
    echo "Female count file has more lines than the male count file." 
    exit 1
else
    echo "Somethind weird is happening and the male and female files do not have the same, or different number of lines."
    exit 1
fi






