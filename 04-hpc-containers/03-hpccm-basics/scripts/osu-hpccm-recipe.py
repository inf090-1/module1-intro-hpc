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
