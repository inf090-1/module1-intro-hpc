#!/bin/bash
#SBATCH --job-name=wps-metgrid
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1G
#SBATCH --output=wps_metgrid-all.out
#SBATCH --error=wps_metgrid-all.err

# Set ENV variables
CUR_DIR=$(pwd)
DATA_DIR=${CUR_DIR}/data                
WRF_INP=${CUR_DIR}/input 
WRF_PRE=${CUR_DIR}/pre

# Load modules
module load spack 
module load wps

cd $WRF_PRE
ln -sf $WRF_INP/METGRID.TBL .
ln -sf $WRF_INP/namelist.wps .
metgrid.exe