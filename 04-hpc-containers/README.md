# HPC Containers

This section introduces HPC containers, a practical way to package and run HPC software with a reproducible environment. The lessons below move from using Apptainer as a user, to benchmarking inside containers, and finally to generating container recipes with HPCCM.

## What You Will Learn

- How Apptainer/Singularity works for HPC workloads
- How to run a containerized OSU benchmark on a cluster
- How HPCCM can generate container definitions from Python recipes
- How to combine containers with MPI, network fabrics, and GPU-enabled software stacks

## Lesson Overview

1. [01-apptainer-basics](01-apptainer-basics/README.md) introduces the core Apptainer workflow for HPC users, including pulling images, running commands inside containers, and using GPUs from within a container.
2. [02-apptainer-osu](02-apptainer-osu/README.md) applies Apptainer to OSU Micro-Benchmarks so you can assess latency and bandwidth performance.
3. [03-hpccm-basics](03-hpccm-basics/README.md) shows how HPCCM simplifies container creation by turning a Python recipe into a Dockerfile or Apptainer definition file.

## Suggested Path

If you are new to containers, start with Apptainer basics. If you already know the basics and want a more HPC-focused example, continue with the OSU benchmark guide. If you want to automate container builds and avoid writing long definition files by hand, move on to HPCCM.