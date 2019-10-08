#!/bin/bash
#BATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J findBEST
#SBATCH -e 02.deNovo_A_findBest_maleOnly.%j.err
#SBATCH -o 02.deNovo_A_findBest_maleOnly.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=00:11:11

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

# make best file with only males
cd ${out_dir}
grep _M_ SexMarker_line_count.all.sorted >> SexMarker_line_count.maleOnly.sorted
x=$(( $n + 1 ))
head -${x} SexMarker_line_count.maleOnly.sorted >> SexMarker_line_count.maleOnly.best
sed -i '1d' SexMarker_line_count.maleOnly.best
