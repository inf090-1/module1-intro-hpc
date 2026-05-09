# Hardware (HPC) — Overview

This folder contains short, practical guides and examples to inspect and benchmark hardware on HPC systems. Use these documents to discover CPU, memory, GPU, and network characteristics of login and compute nodes, and to learn simple monitoring and interactive workflows.

Contents

- [1-filesystem](1-filesystem/README.md): Quick checks for your `HOME` and `SCRATCH` spaces, and how to verify filesystem layout both on the head/login node and on allocated compute nodes.
- [2-hardware-checking](2-hardware-checking/README.md): Commands and examples to inspect CPUs, PCI devices, and GPUs (`lscpu`, `lspci`, `nvidia-smi`, `amd-smi`, `nvtop`), plus brief `tmux`/interactive usage for live inspection.
- [3-osu-example](3-osu-example/README.md): MPI microbenchmarks (OSU) for measuring interconnect bandwidth and latency with example scripts and aggregation tools.
