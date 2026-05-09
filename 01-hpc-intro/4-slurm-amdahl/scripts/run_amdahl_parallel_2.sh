#!/bin/bash
#SBATCH -J parallel-amdahl-2
#SBATCH -p cpu
#SBATCH -n 2
#SBATCH --time=00:05:00
#SBATCH -o amdahl-parallel-2-%j.out

module load python/3.13.1
module load mpich

source amdahl-env/bin/activate

mpirun amdahl
