#!/bin/bash
#SBATCH --job-name=osu-bw
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --output=osu_bw.out

module load mpich || true
module load osu-micro-benchmarks || true

mpirun -np 2 osu_bw