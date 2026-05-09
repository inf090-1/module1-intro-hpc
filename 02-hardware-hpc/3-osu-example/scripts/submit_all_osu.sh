#!/bin/bash
# submit_all_osu.sh

set -e

RESULTS_DIR="osu_results"
mkdir -p "$RESULTS_DIR"

# Load required modules
module load python || true

# Activate or create venv if needed
if [ ! -d "osu-env" ]; then
    echo "Creating virtual environment..."
    python3 -m venv osu-env
fi
source osu-env/bin/activate

# Install pandas and matplotlib if not present
pip install -q pandas 2>/dev/null || true
pip install -q matplotlib 2>/dev/null || true

echo "Submitting single node jobs for OSU latency and bandwidth..."

cat > "${RESULTS_DIR}/submit_single_node_latency_and_bandwidth.sh" <<'SLURMEOF'
#!/bin/bash
#SBATCH --job-name=osu-single-node-sweep
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --time=00:10:00

export UNBUFFERED=1
# Load environment
module load mpich || true
module load omb || true

# Run 3 times and collect output
echo "=== OSU latency and bandwidth tests ===" > "RESULTS_DIR_PLACEHOLDER/osu_single_node.txt"
for trial in 1 2 3; do
    echo "Trial $trial/3..." 
    mpirun -np 2 osu_latency -m 1:1024> "RESULTS_DIR_PLACEHOLDER/single_node_latency_trial${trial}.txt" 2>&1
    mpirun -np 2 osu_bw -m 1:1024 > "RESULTS_DIR_PLACEHOLDER/single_node_bw_trial${trial}.txt" 2>&1
done

SLURMEOF

# Replace placeholders
sed -i "s|RESULTS_DIR_PLACEHOLDER|${RESULTS_DIR}|g" "${RESULTS_DIR}/submit_single_node_latency_and_bandwidth.sh"
sbatch "${RESULTS_DIR}/submit_single_node_latency_and_bandwidth.sh"

echo "Submitting multi-node jobs for OSU latency and bandwidth..."
cat > "${RESULTS_DIR}/submit_multinode_latency_and_bandwidth.sh" <<'SLURMEOF'
#!/bin/bash
#SBATCH --job-name=osu-multinode-sweep
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1

export UNBUFFERED=1
# Load environment
module load mpich || true
module load omb || true

# Run 3 times and collect output
echo "=== OSU multi-node latency and bandwidth tests ===" > "RESULTS_DIR_PLACEHOLDER/osu_multinode.txt"
interface=eth
echo "Testing interface: $interface" > "RESULTS_DIR_PLACEHOLDER/osu_multinode.txt"
for trial in 1 2 3; do
    echo "Trial $trial/3..." 
    mpirun -np 2 osu_latency -m 1:1024 > "RESULTS_DIR_PLACEHOLDER/multinode_${interface}_latency_trial${trial}.txt" 2>&1
    mpirun -np 2 osu_bw -m 1:1024 > "RESULTS_DIR_PLACEHOLDER/multinode_${interface}_bw_trial${trial}.txt" 2>&1
done


SLURMEOF

# Replace placeholders
sed -i "s|RESULTS_DIR_PLACEHOLDER|${RESULTS_DIR}|g" "${RESULTS_DIR}/submit_multinode_latency_and_bandwidth.sh"
sbatch "${RESULTS_DIR}/submit_multinode_latency_and_bandwidth.sh"

echo "All jobs submitted. Wait for results in ${RESULTS_DIR}/"
echo "Next: run 'python3 scripts/aggregate_osu_results.py' to parse and plot results"
