#!/bin/bash
#SBATCH --job-name=wps-ungrid
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1G
#SBATCH --output=wps_ungrid-all.out
#SBATCH --error=wps_ungrid-all.err

# Set ENV variables
CUR_DIR=$(pwd)
DATA_DIR=${CUR_DIR}/data                
WRF_INP=${CUR_DIR}/input 
WRF_PRE=${CUR_DIR}/pre

mkdir -p $WRF_PRE

# Load modules
module load spack 
module load wps

## GRIB data
# Uncompress matthew GRIB data if not already done
if [ ! -d "$DATA_DIR/matthew" ]; then
    tar -xvf $DATA_DIR/matthew_1deg.tar.gz -C $DATA_DIR
fi

cd $DATA_DIR/matthew
ln -sf $WRF_INP/Vtable.GFS Vtable
link_grib.csh ./fnl
ln -sf $WRF_INP/namelist.wps .
# Update namelist.wps prefix for WPS data
sed -i "s/^.*prefix.*$/    prefix = 'FILE',/" namelist.wps
ungrib.exe
# Create symbolic links for ungrib output files FILE:2016-10-06_00 FILE:2016-10-06_06 ...
for f in FILE:*; do
  ln -sf "$PWD/$f" $WRF_PRE
done

## SST data
# Uncompress matthew SST data if not already done
if [ ! -d "$DATA_DIR/matthew_sst" ]; then
    tar -xvf $DATA_DIR/matthew_sst.tar.gz -C $DATA_DIR
fi

cd $DATA_DIR/matthew_sst
ln -sf $WRF_INP/Vtable.SST Vtable
link_grib.csh ./rtg_sst_grb
ln -sf $WRF_INP/namelist.wps .
# Update namelist.wps prefix for SST data
sed -i "s/^.*prefix.*$/    prefix = 'SST',/" namelist.wps
ungrib.exe
# Create symbolic links for ungrib output files
for f in SST:*; do
  ln -sf "$PWD/$f" $WRF_PRE
done