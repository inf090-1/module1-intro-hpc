# A quick introduction to HPC Container Maker (HPCCM)

In the previous guides, we manually created an Apptainer definition file to build a container with the OSU micro-benchmarks. This process can be time-consuming and error-prone, especially for complex software stacks. [HPCCM (HPC Container Maker)](https://github.com/NVIDIA/hpc-container-maker) is a tool that simplifies this process by allowing you to write a Python script (called a recipe) that describes your container. HPCCM then generates the appropriate Dockerfile or Singularity/Apptainer definition file for you. This tutorial will cover the basics of using HPCCM to create HPC containers.


## 1. Install HPCCM (local machine)

HPCCM can be installed with pip, conda and Spack:

```bash
pip install hpccm
# or
conda install -c conda-forge hpccm
# or
spack install py-hpccm
```

In the case of INFO090 HPC cluster, HPCCM is already available as a module. You can load it with:

```bash
module load py-hpccm
```

Then, to verify the installation, run:

```bash
hpccm --version
```

You should see output similar to `26.1.0`, which indicates that HPCCM is installed and ready to use.


## 2. Writing an HPCCM recipe

HPCCM supports three main workflows for generating container specifications (recipes):

- Application recipe: generate the whole container spec from a Python recipe.
- Base image generation: create a reusable HPC base image first, then build apps on top.
- Template generation: emit a container spec and edit it manually afterward.

We will focus on the application recipe workflow for this tutorial. The HPCCM recipes are Python scripts. A minimal recipe `recipe.py` looks like this:

```python
#!/usr/bin/env python
import hpccm

Stage0 = hpccm.Stage()
Stage0 += baseimage(image='ubuntu:24.04')
Stage0 += gnu()
Stage0 += openmpi(cuda=False, infiniband=False)

print(Stage0)
```
A few notes on the recipe structure:

- `baseimage(...)` selects the starting container image.
- Building blocks such as `gnu()` and `openmpi()` add HPC software.
- `Stage0` is the first build stage.

To generate a container specification, you run the HPCCM command line tool with your recipe. The output can be in Dockerfile format or Apptainer/Singularity definition file format.

Save the recipe as `recipe.py`, then generate a container file:

```bash
# Dockerfile output
hpccm --recipe recipe.py --format docker > Dockerfile

# Apptainer / Singularity output
hpccm --recipe recipe.py --format singularity > apptainer.def
```

The HPCCM output is not the final image. It is the container specification that you build with Docker or Apptainer/Singularity. 

For example, to build the Apptainer image from the generated Apptainer/Singularity definition file:

```bash
apptainer build my-hpc-image.sif apptainer.def
```

## 3. The HPCCM recipe building blocks

HPCCM building blocks hide a lot of container-specific boilerplate. In the previous guide, we would have had to write many commands to install a package. HPCCM hides much of that complexity for us. Common examples include:

- `gnu` for GNU compilers
- `openmpi` or `mpich` for MPI
- `hdf5`, `netcdf`, `fftw`, `kokkos`, `openblas`
- `cuda`, `nvhpc`, `nccl`, `ucx`, `rdma_core`
- `python` and `pip` for Python-based stacks

Examples:

```python
Stage0 += gnu(fortran=False)
Stage0 += openmpi(cuda=True, infiniband=True)
Stage0 += hdf5()
```

Many building blocks expose a `runtime()` method so the build stage can be split from the final runtime image.

## 4. User Arguments

HPCCM recipes can accept user-supplied arguments at runtime with the `--userarg` flag. This makes recipes more flexible and reusable. For example, you can specify the CUDA version as a user argument for a recipe file named `cuda-recipe.py`:

```python
#!/usr/bin/env python
from packaging.version import Version

cuda_version = USERARG.get('cuda', '12.4')

if Version(cuda_version) < Version('12.0'):
    raise RuntimeError(f'Invalid CUDA version: {cuda_version}. Must be >= 12.0')

Stage0 += baseimage(image=f'nvidia/cuda:{cuda_version}-devel-ubuntu24.04')
```

Then, when you run the HPCCM command, you can pass the desired CUDA version:

```bash
hpccm --recipe cuda-recipe.py --userarg cuda=12.8
```

This makes one recipe reusable across multiple versions or hardware targets.

## 5. A Good Practice: OSU Micro-Benchmarks Recipe

As in the previous guides, you can practice writing an HPCCM recipe named `osu-hpccm-recipe.py` to build a container with the OSU micro-benchmarks. The steps you would follow are:

1. Choose a base image (e.g., `ubuntu:22.04`).
2. Add a compiler building block.
3. Add MPICH with UCX support for InfiniBand.
4. Add a generic autotools building block to build the OSU micro-benchmarks from source.
5. Switch to the runtime stage and set environment variables to include the OSU binaries in the PATH.

```py
#!/usr/bin/env python3
import hpccm

# Create the stage
Stage0 = hpccm.Stage()

# 1. Base Image
Stage0 += baseimage(image='ubuntu:22.04')

# 2. Basic Tools and GNU Compiler
compiler = gnu()
Stage0 += compiler

# 3. MLNX_OFED (InfiniBand Drivers)
Stage0 += mlnx_ofed(version='24.10-3.2.5.0')

# 4. MPICH 
Stage0 += ucx(version='1.15.0', cuda=False) # Recommended middleware for MPICH + IB
Stage0 += mpich(version='4.2.3', device='ch4:ucx', disable_fortran=True)

# 5. OSU Micro-Benchmarks
# Use generic_autotools to handle the build process
Stage0 += generic_autotools(
    build_environment={'CC': 'mpicc', 'CXX': 'mpicxx'},
    prefix='/usr/local/osu',
    url='http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.5.1.tar.gz')

# 6. Environment Configuration
# HPCCM's environment block handles the exports for the final container
base_path = '/usr/local/osu/libexec/osu-micro-benchmarks'
Stage0 += environment(variables={
        'PATH': '{0}:{0}/mpi/collective:{0}/mpi/one-sided:{0}/mpi/pt2pt:{0}/mpi/startup:$PATH'.format(base_path)
        })

# Print the resulting definition (Apptainer or Docker format)
print(Stage0)
```

Then, you can generate the container specification and build the image as described in the previous section.

```bash
# Generate the Apptainer definition file
hpccm --recipe osu-hpccm-recipe.py --format singularity > osu-hpccm.def
# Build the Apptainer image
apptainer build osu-hpccm.sif osu-hpccm.def
```

A sample generated Apptainer definition file can be found in [`osu-hpccm.def`](./scripts/osu-hpccm.def). You can inspect the file to see how HPCCM translates the Python recipe into a container specification.

Finally, you can run the OSU benchmarks inside the container to verify that everything is working correctly.

```bash
apptainer exec osu-hpccm.sif osu_bw
```

## Further Reading

- HPCCM getting started: https://github.com/NVIDIA/hpc-container-maker/blob/master/docs/getting_started.md
- HPCCM tutorial: https://github.com/NVIDIA/hpc-container-maker/blob/master/docs/tutorial.md
- HPCCM workflows: https://github.com/NVIDIA/hpc-container-maker/blob/master/docs/workflows.md
- HPCCM building blocks reference: https://github.com/NVIDIA/hpc-container-maker/blob/master/docs/building_blocks.md
- HPCCM primitives reference: https://github.com/NVIDIA/hpc-container-maker/blob/master/docs/primitives.md
