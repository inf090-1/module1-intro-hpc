#!/bin/bash
#SBATCH --job-name=wps-geogrid
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1G
#SBATCH --output=wps_geogrid-all.out
#SBATCH --error=wps_geogrid-all.err

# Set ENV variables
CUR_DIR=$(pwd)
DATA_DIR=${CUR_DIR}/data                
WRF_INP=${CUR_DIR}/input 
WRF_PRE=${CUR_DIR}/pre
mkdir -p $WRF_PRE

# Load modules
module load spack 
module load wps

cd $WRF_PRE
# Create symbolic links for geogrid input files
ln -sf $WRF_INP/GEOGRID.TBL .
ln -sf $WRF_INP/namelist.wps .

# Run
geogrid.exe