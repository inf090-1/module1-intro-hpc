# Day 1: Introduction to HPC

This folder contains the first hands-on guides for getting started with the HPC environment used in the course. The guides are arranged in the order you are most likely to need them:

1. connect to the cluster,
2. move files in and out,
3. load software modules,
4. launch jobs with Slurm,
5. run a small Amdahl's Law example, and
6. use essential command-line tools.

Use the table below to jump to any guide, or follow the recommended path if you are starting from scratch.

## Guide Index

| Guide | What it covers |
|---|---|
| [0-ssh-login](0-ssh-login/README.md) | How to connect to the cluster with SSH and prepare your session. |
| [1-transfer-files](1-transfer-files/README.md) | Copying data with `scp`, `rsync`, and other common transfer workflows. |
| [2-lmod-modules](2-lmod-modules/README.md) | Loading and managing software with the Lmod module system. |
| [3-slurm-basics](3-slurm-basics/README.md) | Checking partitions with `sinfo`, running simple programs with `srun`, and submitting jobs with `sbatch`. |
| [4-slurm-amdahl](4-slurm-amdahl/README.md) | Running the Amdahl's Law example with Slurm and analyzing speedup. |
| [5-cli-tools](5-cli-tools/README.md) | Using essential command-line tools for HPC workflows. |

## Recommended Path

If you are using the material for the first time, follow the guides in order. Each one
builds on the previous step and introduces a new part of the workflow you will use on the
cluster.

- Start with [0-ssh-login](0-ssh-login/README.md) to connect to the cluster.
- Continue with [1-transfer-files](1-transfer-files/README.md) to move data in and out.
- Learn software management in [2-lmod-modules](2-lmod-modules/README.md).
- Submit your first batch jobs in [3-slurm-basics](3-slurm-basics/README.md).
- Move on to [4-slurm-amdahl](4-slurm-amdahl/README.md) for a small parallel workload example.
- Finish with [5-cli-tools](5-cli-tools/README.md) for essential command-line tools.

