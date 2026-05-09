# Introduction to HPC - Guide Index

This folder collects the first set of hands-on guides for getting started with the HPC
environment used in the course. The guides are arranged in a practical order:

1. connect to the cluster,
2. move files in and out,
3. understand the cluster filesystem layout,
4. load software modules,
5. launch jobs with Slurm,
6. run a small Amdahl's Law example with Slurm, and

Use the table below as the entry point into each guide.

## Guide Index

| Guide | What it covers |
|---|---|
| [0-ssh-login](0-ssh-login/README.md) | How to connect to the cluster with SSH and prepare your session. |
| [1-transfer-files](1-transfer-files/README.md) | Copying data with `scp`, `rsync`, and other common transfer workflows. |
| [2-lmod-modules](2-lmod-modules/README.md) | Loading and managing software with the Lmod module system. |
| [3-slurm-basics](3-slurm-basics/README.md) | Checking partitions with `sinfo`, running simple programs with `srun`, and submitting jobs with `sbatch`. |
| [4-slurm-amdahl](4-slurm-amdahl/README.md) | Running the Amdahl's Law example with Slurm and analyzing speedup. |
| [5-filesystem](5-filesystem/README.md) | How `$HOME`, `$SCRATCH`, and node-local `/tmp` behave on the headnode and compute nodes. |

## Recommended Path

If you are following the material for the first time, read the guides in order. Each one
builds on the previous step and introduces one part of the workflow you will use on the
cluster.

- Start with [0-ssh-login](0-ssh-login/README.md) to get access.
- Continue with [1-transfer-files](1-transfer-files/README.md) to move your data.
- Learn the filesystem layout in [5-filesystem](5-filesystem/README.md) so you know where data should live.
- Learn software management in [2-lmod-modules](2-lmod-modules/README.md).
- Submit your first batch jobs in [3-slurm-basics](3-slurm-basics/README.md).
- Finish with [4-slurm-amdahl](4-slurm-amdahl/README.md) for a small parallel workload example.

## Why This Order

The sequence mirrors the typical HPC workflow: connect, stage files, understand the
filesystem layout, load the right software, submit a job, then analyze performance.
By the time you reach the last guide, you will have seen all the pieces needed to run
and evaluate a simple parallel application.

