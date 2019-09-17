This directory contains information relevant to finding sex markers in Delta Smelt.
Directory and File descriptions:
	DS_sex-marker.pheno.ybin == phenotype file for association study in ANGSD. Created with the following command `for i in /home/sejoslin/projects/sexMarker/data/RAD_alignments/*.stats; do base=$(echo ${i} | rev | cut -d/ -f1 | rev) ; sex=$(echo ${base} | cut -d_ -f3); if [[ ${sex} == "M" ]]; then echo "0" >> DS_sex-marker.pheno.ybin; elif [[ ${sex} == "F" ]]; then echo "1" >> DS_sex-marker.pheno.ybin; else echo "Error ${sex} does not exist!"; fi; done`

