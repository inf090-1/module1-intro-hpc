#!/bin/bash
#SBATCH --job-name=osu-single-node
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --output=osu_single_node.out

module load mpich || true
module load omb || true

echo "Running on single node..."
mpirun -np 2 osu_latency
mpirun -np 2 osu_bw
