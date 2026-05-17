# Real-World HPC Workflows

This folder collects the last practical examples in the Introduction to HPC module. The goal is to show how the ideas from the earlier lessons fit together in real scientific workflows, not just in isolated exercises.

By the end of these examples, you should be able to move comfortably between:

- remote login and file handling
- software environments and reproducible builds
- SLURM job submission and resource requests
- containers for application portability
- parallel execution and output inspection
- post-processing and scientific visualization

## What Is Included

| Example | Focus | Main HPC Concepts |
| --- | --- | --- |
| [WRF](wrf/README.md) | Weather forecasting workflow | module loading, Spack-based environments, preprocessing pipelines, restart files, Jupyter-based execution |
| [OpenFOAM](openfoam/README.md) | CFD workflow in a container | Apptainer, mesh preparation, SLURM submission, sequential execution, ParaView visualization |

## How To Use This Folder

Start with the example that best matches what you want to practice:

1. Read the [WRF overview](wrf/README.md) if you want to see a full atmospheric modeling workflow built around notebooks and restartable runs.
2. Read the [OpenFOAM guide](openfoam/README.md) if you want a container-based simulation workflow with mesh conversion, validation, and result inspection.
3. Compare both examples after that to see how the same HPC ideas appear in different scientific domains.

## Learning Goals

These final examples connect the earlier module topics into complete workflows:

- module and package management from the software stack lessons
- batch scripting and job scheduling from the SLURM lessons
- filesystem organization and data staging from the storage and system lessons
- containerized execution from the Apptainer lessons
- performance awareness from the parallelism and Amdahl examples

The important takeaway is that HPC is not only about running code faster. It is about preparing data, choosing the right execution environment, requesting the right resources, and validating the results after the run completes.

## Suggested Sequence

1. Review the WRF materials first if you want the more complete end-to-end workflow.
2. Then move to OpenFOAM to see a second real-world application with a different software stack and execution style.
3. Revisit the earlier module sections whenever a step in these capstones refers to modules, SLURM, containers, or parallel execution.

## Note

These examples are intentionally practical. Some steps are written as guided workflows, while others assume you can connect them back to the earlier lessons in this module. If a command or file path looks unfamiliar, check the corresponding lesson from the module index and then return here.
