#!/bin/bash
#SBATCH --job-name=apptainer_pytorch_gpu
#SBATCH --output=apptainer_pytorch_gpu.out
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

srun apptainer exec amd_pytorch.sif python3 pytorch_gpu.py
