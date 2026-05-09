#!/bin/bash
#SBATCH -J hello-world      # Job name
#SBATCH -p cpu              # Partition (queue)
#SBATCH -N 1                # Number of nodes
#SBATCH -n 1                # Number of tasks
#SBATCH -t 00:01:00         # Walltime (hh:mm:ss)

echo -n "This script is running on "
hostname
echo "I will sleep for 10 seconds so you can see me in the queue..."
sleep 10
