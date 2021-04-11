#!/bin/bash -l
#SBATCH -J alignRAD
#SBATCH -e slurm/j%j.align_RAD_2_M_ipa_cb_w_bowtie.err
#SBATCH -o slurm/j%j.align_RAD_2_M_ipa_cb_w_bowtie.out
#SBATCH --ntasks=20
#SBATCH -p high
#SBATCH --time=04:00:00
#SBATCH --mem=32G

# Script to align RAD data to combined genome using bowtie2

###############
###  SETUP  ###
###############

# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate conda env
conda activate bowtie2

# fail on weird errors
set -o nounset
set -o errexit
set -x
set -e

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"

### MAKE CHANGES ###
prefix="RX"  # library directory prefix
# directories
#script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-RAD-data"
out_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/00-alignments_M_bowtie2"
# files
reference="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/04-linkage_map/out_chromonomer/CHRR_integrated.fa"
###  END  ###


#############
###  RUN  ###
#############

# make output directory
[ -d ${out_dir} ] || mkdir -p ${out_dir}
cd ${out_dir}
mkdir -p slurm

# symlink ref
ref_short=$(echo $reference | rev | cut -f1 -d/ | rev)
ref_pre=$(echo $ref_short | cut -f1 -d.)
[ -h ${ref_short} ] || ln -s ${reference} ${ref_short}

# build database
echo "Building bowtie2 database from reference genome"
bowtie2-build --threads ${SLURM_NTASKS} -f ${ref_short} ${ref_pre}
echo "    Complete!"
echo ""

# create & launch independent scripts
echo "Creating alignment scripts:"
for i in ${data_dir}/*R1.fastq
do
filename=$(echo ${i} | rev | cut -f1 -d/ | rev)
prefix=$(basename ${filename} _R1.fastq)
j=$(echo ${prefix} | cut -f1 -d_)
cat << EOT >> ${prefix}.slurm
#!/bin/bash -l
#SBATCH -J aln_${j}
#SBATCH -e slurm/j%j.align_${prefix}.err
#SBATCH -o slurm/j%j.align_${prefix}.out
#SBATCH --ntasks=12
#SBATCH -p high
#SBATCH --time=24:00:00
#SBATCH --mem=32G

# SETUP
## initialize conda
. ~/miniconda3/etc/profile.d/conda.sh
## activate conda env
conda activate bowtie2
## fail on weird errors
set -o nounset
set -o errexit
set -x
set -e

hostname
start=\`date +%s\`
echo "My SLURM_JOB_ID: \$SLURM_JOB_ID"

R1="${data_dir}/${prefix}_R1.fastq"
R2="${data_dir}/${prefix}_R2.fastq"

cd ${out_dir}

# RUN
## alignment
bowtie2 --end-to-end -p \${SLURM_NTASKS} -x ${ref_pre} -1 \${R1} -2 \${R2} -S ${prefix}.sam
## make bams
conda activate samtools
samtools view -Sb ${prefix}.sam | samtools sort -n - | samtools fixmate -m - ${prefix}.sort-n.fixmate-m.bam
samtools sort ${prefix}.sort-n.fixmate-m.bam | samtools markdup -r - ${prefix}.sort-n.fixmate-m.markdup-r.bam
samtools index ${prefix}.sort-n.fixmate-m.markdup-r.bam

sstat --format 'JobID,MaxRSS,AveCPU' -P \${SLURM_JOB_ID}.batch
end=\`date +%s\`
runtime=\$((end-start))
echo "Runtime : "\${runtime}
EOT
echo "Slurm script for ${prefix} complete"
echo "    Submitting batch job"
sbatch ${prefix}.slurm
echo "    Success! Moving on to the next one..."
echo ""
done

# make comma separated list of R1 & R2 files
## R1
#for i in ${data_dir}/*R1.fastq
#do
#    echo ${i} >> R1.bamlist
#done
#sed -i ':a;N;$!ba;s/\n/,/g' R1.bamlist
#R1=$(cat R1.bamlist)
#*R1.fastq
## R2
#for i in ${data_dir}/*R2.fastq
#do
#    echo ${i} >> R2.bamlist
#done
#sed -i ':a;N;$!ba;s/\n/,/g' R2.bamlist
#R2=$(cat R2.bamlist)


# align RAD files to genome
#bowtie2 --end-to-end -p ${SLURM_NTASKS} -x ${ref_pre} -1 ${R1} -2 ${R2}



sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch
end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
