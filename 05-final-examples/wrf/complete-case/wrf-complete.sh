#!/bin/bash

# WPS jobs
jid_ungrid=$(sbatch --parsable scripts/wps-ungrid.slurm)
jid_geogrid=$(sbatch --parsable scripts/wps-geogrid.slurm)
jid_metgrid=$(sbatch --parsable --dependency=afterany:$jid_ungrid:$jid_geogrid scripts/wps-metgrid.slurm)

# WRF jobs
jid_real=$(sbatch --parsable --dependency=afterany:$jid_metgrid --job-name=wrf-complete scripts/wrf-real.slurm)
sbatch --dependency=singleton --job-name=wrf-complete scripts/wrf-sim.slurm

# show dependencies in squeue output:
squeue -u $USER -o "%.8A %.4C %.10m %.20E"
