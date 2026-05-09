# Module 1 — Introduction to HPC

This module introduces the foundational concepts and daily workflows of High-Performance Computing (HPC). These guides are designed to get you up and running on an HPC cluster, understand storage layouts, manage software environments, run benchmarks, and build containers. The material is practical and hands-on, with a focus on real-world tools like SSH, Slurm, Lmod, Spack, Apptainer, and HPCCM.

**What You Will Learn**

- Core HPC architecture and node roles (login, compute, storage)
- How to use SSH, the shell, and shared filesystems on the cluster
- How to compose and submit Slurm batch scripts and interactive jobs
- Managing software with Lmod modules and creating reproducible environments
- Building and using containers, then tying the workflow together in a final example

**Lesson Overview**

- [01-hpc-intro](01-hpc-intro/README.md): cluster architecture, shell basics, filesystem layout, and Slurm/Amdahl examples.
- [02-osu-example](02-osu-example/README.md): running OSU micro-benchmarks; latency/bandwidth experiments and result aggregation.