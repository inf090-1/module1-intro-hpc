# Module 1 — Introduction to HPC

This module introduces the foundational concepts and daily workflows of High-Performance Computing (HPC). These guides are designed to get you up and running on an HPC cluster, manage software environments, run benchmarks, and build containers. The material is practical and hands-on, with a focus on real-world tools like SLURM, Lmod, Spack, Apptainer, and HPCCM.

**What You Will Learn**

- Core HPC architecture and node roles (login, compute, storage)
- How to compose and submit SLURM batch scripts and interactive jobs
- How to request GPUs and use job arrays
- Managing software with Lmod/Lua modules and creating reproducible environments
- Running simple MPI benchmarks and packaging software with Spack

**Lesson Overview**

- [01-hpc-intro](01-hpc-intro/README.md): cluster architecture, shell basics, and Amdahl examples.
- [02-osu-example](02-osu-example/README.md): running OSU micro-benchmarks; latency/bandwidth experiments and result aggregation.
- [03-software-stack](03-software-stack/README.md): software stacks, Spack basics, and creating local Spack packages.
- [04-hpc-containers](04-hpc-containers/README.md): container workflows with Apptainer and HPCCM; building reproducible images.
- [05-final-examples](05-final-examples/README.md): two real-world capstones that tie together SLURM, modules, container builds, package management, and scientific visualization.

**Suggested Path**

1. Start with [01-hpc-intro](01-hpc-intro/README.md) to learn cluster concepts and SLURM basics.
2. Move to [03-software-stack](03-software-stack/README.md) to understand environment and package management with Spack.
3. Run benchmarks in [02-osu-example](02-osu-example/README.md) and use the scripts in the containers lesson.
4. Read [04-hpc-containers](04-hpc-containers/README.md) for container-building patterns and automated recipes.
5. Finish with [05-final-examples](05-final-examples/README.md) to apply the full workflow in compact real-world projects.
