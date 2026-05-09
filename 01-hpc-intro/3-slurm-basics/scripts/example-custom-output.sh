#!/bin/bash
#SBATCH -J output-test
#SBATCH -p cpu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 00:05:00
#SBATCH -o output_test_%j.out    # Standard output (%j expands to the Job ID)
#SBATCH -e output_test_%j.err    # Standard error

echo "This message will be sent to the .out file (stdout)"
echo "This error message will be sent to the .err file (stderr)" >&2
