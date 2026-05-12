# Day 3: Software Stack with Spack

This part of the course introduces Spack as the main tool for managing HPC software in a reproducible way. It is split into two lessons that build on each other: first, you learn how to use Spack to discover, install, load, and clean up software; then, you move one step further and learn how to create a custom Spack package for software that is not already available in the upstream repository.

The goal is to connect day-to-day package management with the software lifecycle you are likely to encounter on HPC systems. By the end of this section, you should be able to install and use existing packages, inspect their dependencies and variants, and understand the basic structure of a Spack recipe for packaging new software.

## Lessons

- [01-spack-basics](./01-spack-basics/README.md): introduction to Spack commands, package discovery, installation, loading, dependency inspection, and cleanup.
- [02-spack-package-creation](./02-spack-package-creation/README.md): creating a local Spack package recipe and registering it in a custom repository.

## What You Will Learn

- How Spack fits into the HPC software stack.
- How to search for packages, inspect metadata, and install software with different compilers and options.
- How to manage installed software in your environment with `spack load`, `spack find`, and `spack uninstall`.
- How to describe a new package with a `package.py` recipe and add it to a local Spack repository.

## Suggested Flow

Start with [01-spack-basics](./01-spack-basics/README.md) to get comfortable with the core workflow. Once you understand how Spack manages existing software, continue with [02-spack-package-creation](./02-spack-package-creation/README.md) to see how custom software is packaged and installed.
