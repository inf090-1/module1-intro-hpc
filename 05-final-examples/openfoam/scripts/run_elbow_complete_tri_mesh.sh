#!/bin/bash
#SBATCH --job-name=openfoam-elbow-tri
#SBATCH --partition=cpu
#SBATCH --nodes=1                # Single node
#SBATCH --ntasks=1               # 1 processor (core)
#SBATCH --mem=4G                 # 4 GB RAM
#SBATCH --output=openfoam_elbow_tri.out   
#SBATCH --error=openfoam_elbow_tri.err

CASEDIR=$(pwd)/elbow

echo "=========================================="
echo "OpenFOAM - Elbow Case - triangular grid"
echo "=========================================="

# Clean previous run 
for i in {1..100}; do [ -d "elbow/$i" ] && rm -rf "elbow/$i"; done

# Creating mesh for foam format
apptainer exec openfoam.sif bash -c "source /opt/openfoam6/etc/bashrc && fluentMeshToFoam -case $CASEDIR elbow_tri.msh" 

# Check mesh quality
apptainer exec openfoam.sif bash -c "source /opt/openfoam6/etc/bashrc && checkMesh -case $CASEDIR"

# Run simulation
apptainer exec openfoam.sif bash -c "source /opt/openfoam6/etc/bashrc && icoFoam -case $CASEDIR"