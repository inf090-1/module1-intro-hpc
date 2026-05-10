#!/bin/bash
#SBATCH --job-name=osu-latency
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --output=osu_latency.out

module load mpich || true
module load osu-micro-benchmarks || true

mpirun -np 2 osu_latency