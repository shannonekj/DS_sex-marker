#!/bin/bash -l
#SBATCH -J dpth_F
#SBATCH -e slurm/j%j.get_depths.err
#SBATCH -o slurm/j%j.get_depths.out
#SBATCH -p high 

