#!/bin/bash
#SBATCH --job-name=openfoam_elbow
#SBATCH --partition=cpu
#SBATCH --nodes=1                 # Request 1 physical compute node
#SBATCH --ntasks=1                # Run strictly on 1 CPU core
#SBATCH --mem=4G                  # Allocate 4 GB of RAM
#SBATCH --output=openfoam_elbow.out   # Standard output log
#SBATCH --error=openfoam_elbow.err    # Standard error log

# Define container and directory variables
CASEDIR=$(pwd)/elbow

# Clean previous run 
for i in {1..100}; do [ -d "elbow/$i" ] && rm -rf "elbow/$i"; done

# Run the OpenFOAM solver inside the container
apptainer exec openfoam.sif bash -c "source /opt/openfoam6/etc/bashrc && icoFoam -case $CASEDIR"