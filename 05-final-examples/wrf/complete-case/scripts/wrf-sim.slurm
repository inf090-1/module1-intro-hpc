#!/bin/bash
#SBATCH --job-name=wrf-simulation
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=1G
#SBATCH --output=wrf_simulation-all.out
#SBATCH --error=wrf_simulation-all.err

# Set ENV variables
CUR_DIR=$(pwd)            
WRF_RUN=${CUR_DIR}/rundir
WRF_INP=${CUR_DIR}/input
WRF_REAL=${CUR_DIR}/real
SRUN_FLAGS="-n $SLURM_NTASKS"

# Clear previous outputs and create new one
rm -rf $WRF_RUN && mkdir -p $WRF_RUN

# Load modules
module load spack 
module load wrf

# Move to WRF_RUN directory and link control files for wrf.exe
cd ${WRF_RUN}
ln -sfn ${WRF_HOME}/run/* .	
cp ${WRF_HOME}/configure.wrf .
ln -sfn ${WRF_INP}/* .
ln -sfn ${WRF_REAL}/* .

# Run 6-hour forecast
srun $SRUN_FLAGS ./wrf.exe