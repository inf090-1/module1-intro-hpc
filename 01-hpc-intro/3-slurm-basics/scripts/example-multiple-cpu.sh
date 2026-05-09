#!/bin/bash
#SBATCH -J multi-cpu-test
#SBATCH -p cpu
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem=2G
#SBATCH -t 00:10:00

echo "This script is running on $(hostname)"
echo "Slurm has allocated $SLURM_NTASKS tasks for this job."
