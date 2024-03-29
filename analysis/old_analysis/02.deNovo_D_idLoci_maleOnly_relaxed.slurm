#!/bin/bash
#BATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J idLocM
#SBATCH -e slurm/02.deNovo_D_idLoci_maleOnly_relaxed.j%j.err
#SBATCH -o slurm/02.deNovo_D_idLoci_maleOnly_relaxed.j%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines



###############
###  SETUP  ###
###############

echo "Setting up variables"

# directories
script_dir="/home/sejoslin/git_repos/DS_sex-marker/scripts"
code_dir="/home/sejoslin/scripts"
data_dir="/group/millermrgrp2/shannon/projects/DS_sex-marker/01-RAD_deNovo_relaxed/maleOnly"

# other
prefix="SexMarker_M_relaxed"
nInd="4"

#############
###  RUN  ###
#############

###  Modify Identify Loci Script  ###
cd ${script_dir}
cat << PARAM >> IdentifyLoci3.${prefix}.pl
#!/usr/bin/perl

#######################################################################################
\$max_alignment_score = 60;
\$divergence_factor = 2;
\$min_count = 0; #zero turns off to use min_flag instead
\$min_flag = 0; #zero turns off to use min_count instead
\$max_internal_alignments = 1; # use 0 for sex chromosome, 1 if diploid
\$min_internal_alignments = 0;
\$max_external_alignments = 6; # twice the df of the total number of samples (i.e. individuals) in the alignment
\$min_external_alignments = 3; # approximately half of the df of the total number of samples (i.e. individuals) in the alignment
\$max_total_alignments = 7; # max_ext_align + max_int_align
\$min_total_alignments = 3; # min_ext_align + min_int_align
\$min_alleles = 1;
\$max_alleles = 4;
\$min_samples_per_allele = 1;
\$max_samples_per_allele = 4; # total number of samples (i.e. individuals) in the alignment
#######################################################################################
PARAM

tail -165 ${code_dir}/IdentifyLoci3.pl >> IdentifyLoci3.${prefix}.pl
chmod a+x IdentifyLoci3.${prefix}.pl


##  RUN scripts to ID loci
echo "Running RAD_deNovo_idLoci.sh"
echo ""
bash ${script_dir}/RAD_deNovo_idLoci.sh ${data_dir} ${script_dir} ${code_dir} ${prefix}

# grab the first instance of all the sequences
cd ${data_dir}
grep -A 1 --no-group-separator "_1" ${prefix}.simple.loci >> ${prefix}.simple._1.loci
chmod a=r ${prefix}.simple._1.loci
