#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J sexAssoc
#SBATCH -e slurm/04.run_sexAssoc.j%j.err
#SBATCH -o slurm/04.run_sexAssoc.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=16:00:00
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
script_dir="/home/sejoslin/git_repos/${proj}/scripts"
data_dir="/home/sejoslin/projects/sexMarker/data"
bam_dir="${data_dir}/RAD_alignments"
out_dir="${data_dir}/doAssociation"

# files
	# make bam
cd ${bam_dir}
ls -al ${bam_dir}/*.sort.proper.rmdup.bam | awk '{print $9}' >> ${bam_dir}/sex.bamlist
bamlist="${bam_dir}/sex.bamlist"
ybin="/home/sejoslin/git_repos/DS_sex-marker/metadata/DS_sex-marker.pheno.ybin"



#############
###  RUN  ###
#############

bash ${script_dir}/doAssoc.sh ${out_dir} ${bamlist} ${proj} ${ybin}



end=`date +%s`
runtime=$((end-start))
echo "Runtime : "${runtime}
