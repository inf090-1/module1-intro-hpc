#!/bin/bash
#SBATCH --job-name=osu-bandwidth
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --output=osu_bw.out

module load mpich || true
module load omb || true

# Ethernet
echo "Running on Ethernet..."
mpirun -np 2 osu_bw
