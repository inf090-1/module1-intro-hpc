#!/bin/bash
#SBATCH --job-name=wrf-real
#SBATCH --ntasks=1
#SBATCH --output=wrf_real-all.out
#SBATCH --error=wrf_real-all.err

# Set ENV variables
CUR_DIR=$(pwd)            
WRF_INP=${CUR_DIR}/input 
WRF_PRE=${CUR_DIR}/pre
WRF_REAL=${CUR_DIR}/real
mkdir -p $WRF_REAL

# Load modules
module load spack 
module load wrf

# Move to WRF_REAL directory
cd $WRF_REAL

# Link control files for real.exe
ln -sf $WRF_INP/* .
ln -sf $WRF_PRE/* .

# Run
real.exe