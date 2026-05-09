#!/bin/bash
#SBATCH -J serial-amdahl
#SBATCH -p cpu
#SBATCH -n 1
#SBATCH --time=00:05:00
#SBATCH -o amdahl-serial-%j.out

module load python/3.13.1
module load mpich

source amdahl-env/bin/activate

amdahl
