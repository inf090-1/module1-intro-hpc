#!/bin/bash
# submit_all_osu.sh

set -e

RESULTS_DIR="osu_apptainer_results"
mkdir -p "$RESULTS_DIR"

# Load required modules
module load python/3.13.1 || true

# Activate or create venv if needed
if [ ! -d "osu-env" ]; then
    echo "Creating virtual environment..."
    python3 -m venv osu-env
fi
source osu-env/bin/activate

# Install pandas and matplotlib if not present
pip install -q pandas 2>/dev/null || true
pip install -q matplotlib 2>/dev/null || true

echo "Submitting Apptainer OSU latency test..."

cat > "${RESULTS_DIR}/submit_apptainer_osu_latency.sh" <<'SLURMEOF'
#!/bin/bash
#SBATCH --job-name=osu-apptainer-latency
#SBATCH --nodes=2
#SBATCH --ntasks=1

# Load environment
module load mpich || true

# Run 3 times and collect output
for trial in 1 2 3; do
    echo "Trial $trial/3..." 
    mpirun -np 2 apptainer exec osu-mb.sif osu_latency > "RESULTS_DIR_PLACEHOLDER/osu_latency_trial${trial}.txt" 2>&1
done

SLURMEOF

# Replace placeholders
sed -i "s|RESULTS_DIR_PLACEHOLDER|${RESULTS_DIR}|g" "${RESULTS_DIR}/submit_apptainer_osu_latency.sh"
sbatch "${RESULTS_DIR}/submit_apptainer_osu_latency.sh"

echo "Submitting Apptainer OSU bandwidth..."
cat > "${RESULTS_DIR}/submit_apptainer_osu_bandwidth.sh" <<'SLURMEOF'
#!/bin/bash
#SBATCH --job-name=osu-apptainer-bandwidth
#SBATCH --nodes=1
#SBATCH --ntasks=2

# Load environment
module load mpich || true

# Run 3 times and collect output
for trial in 1 2 3; do
    mpirun -np 2 apptainer exec osu-mb.sif osu_bw > "RESULTS_DIR_PLACEHOLDER/osu_bw_trial${trial}.txt" 2>&1
done

SLURMEOF

# Replace placeholders
sed -i "s|RESULTS_DIR_PLACEHOLDER|${RESULTS_DIR}|g" "${RESULTS_DIR}/submit_apptainer_osu_bandwidth.sh"
sbatch "${RESULTS_DIR}/submit_apptainer_osu_bandwidth.sh"

echo "All jobs submitted. Wait for results in ${RESULTS_DIR}/"
echo "Next: run 'python3 scripts/aggregate_apptainer_osu_results.py' to parse and plot results"
