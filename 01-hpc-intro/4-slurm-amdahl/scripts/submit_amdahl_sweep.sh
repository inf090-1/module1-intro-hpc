#!/bin/bash
# submit_amdahl_sweep.sh
# 
# Launches multiple Slurm jobs running the amdahl package with 1, 2, 4, 8 MPI ranks.
# Each run is repeated 3 times for averaging.
# Results are collected for analysis and plotting.

set -e

RESULTS_DIR="amdahl_results"
mkdir -p "${RESULTS_DIR}"

# Load required modules (adjust to match your cluster)
module load python/3.13.1 || true
module load mpich || true

# Activate or create venv if needed
if [ ! -d "amdahl-env" ]; then
    echo "Creating virtual environment..."
    python3 -m venv amdahl-env
fi
source amdahl-env/bin/activate

# Install amdahl, numpy and matplotlib if not present
pip install -q amdahl 2>/dev/null || true
pip install -q numpy 2>/dev/null || true
pip install -q matplotlib 2>/dev/null || true

# Array of rank counts to test
RANKS=(1 2 4 8)

# Job IDs to track
declare -a JOB_IDS

echo "Submitting Slurm jobs for Amdahl's Law sweep..."
for ranks in "${RANKS[@]}"; do
    cat > "${RESULTS_DIR}/submit_${ranks}_ranks.sh" <<'SLURMEOF'
#!/bin/bash
#SBATCH --job-name=amdahl-sweep
#SBATCH --ntasks=RANKS_PLACEHOLDER
#SBATCH --time=00:10:00

# Load environment
module load python/3.13.1 || true
module load mpich || true

# Activate venv
source amdahl-env/bin/activate

# Run 3 times and collect output
echo "=== Amdahl run with RANKS_PLACEHOLDER ranks ===" > "RESULTS_DIR_PLACEHOLDER/amdahl_RANKS_PLACEHOLDER.txt"
for run in 1 2 3; do
    echo "Run $run:" > "RESULTS_DIR_PLACEHOLDER/amdahl_RANKS_PLACEHOLDER.txt"
    mpirun amdahl > "RESULTS_DIR_PLACEHOLDER/amdahl_RANKS_PLACEHOLDER.txt" 2>&1
done
SLURMEOF

    # Replace placeholders
    sed -i "s/RANKS_PLACEHOLDER/${ranks}/g" "${RESULTS_DIR}/submit_${ranks}_ranks.sh"
    sed -i "s|RESULTS_DIR_PLACEHOLDER|${RESULTS_DIR}|g" "${RESULTS_DIR}/submit_${ranks}_ranks.sh"
    
    chmod +x "${RESULTS_DIR}/submit_${ranks}_ranks.sh"
    
    # Submit the job and capture job ID
    job_id=$(sbatch "${RESULTS_DIR}/submit_${ranks}_ranks.sh" | awk '{print $NF}')
    JOB_IDS+=($job_id)
    echo "Submitted job $job_id for ${ranks} ranks"
done

echo "All jobs submitted. Results in ${RESULTS_DIR}/"
echo "Next: run 'python3 parse_plot_amdahl.py' to parse and plot results"
