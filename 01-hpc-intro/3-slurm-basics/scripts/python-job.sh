#!/bin/bash
#SBATCH -J python-job
#SBATCH -p cpu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 00:05:00
#SBATCH -o python-job-%j.out

# 1. Load the Python module
# (Make sure to use the exact version available on the cluster)
module load python/3.13.1

# 2. Verify the environment (good practice for debugging)
echo "Using python from: $(which python3)"
python3 --version

# 3. Run your code
python3 -c "import socket; print('Hello from Python on node:', socket.gethostname())"
