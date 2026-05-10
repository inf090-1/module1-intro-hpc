# Day 2: HPC Hardware and Performance

This folder contains the second set of hands-on guides for working on the HPC cluster. The focus here is on understanding where your data lives, what hardware is available on the nodes you use, and how to measure communication performance with MPI microbenchmarks.

## Contents

- [1-filesystem](1-filesystem/README.md): Learn where to store code, scratch data, and temporary files; compare the filesystem layout on the login node and on compute nodes; and see why `$HOME`, `$SCRATCH`, and `/tmp` behave differently.
- [2-hardware-checking](2-hardware-checking/README.md): Inspect CPU, PCI, and GPU information with tools such as `lscpu`, `lspci`, `top`, `htop`, `nvtop`, `amd-smi`, and `nvidia-smi`, and use interactive jobs to check hardware on a live compute node.
- [3-osu-example](3-osu-example/README.md): Run OSU microbenchmarks to measure latency and bandwidth, and plot the results with a Python script.

## Suggested Path

If you are following the module in order, start with the filesystem guide, then move to hardware inspection, and finish with the OSU benchmark example. That sequence gives you the practical context you need before analyzing communication performance.
