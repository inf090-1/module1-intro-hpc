# A quick introduction to Apptainer for HPC users

Apptainer (formerly Singularity) is a containerization platform designed for HPC environments. It allows you to create and run containers that package applications and their dependencies, ensuring consistent execution across different systems. In this way, you can create your container on your laptop and deploy it on an HPC cluster or any other system. This guide provides a quick introduction to using Apptainer on the INF0090 HPC cluster.

> **Note:** You can follow this guide on any Linux system with Apptainer installed, but some commands (especially those involving Slurm) are specific to HPC clusters. 

## 1. Check Apptainer

You can check if Apptainer is installed and view its version with:
```bash
apptainer --version
```
If you want a general overview of the available `apptainer` commands, run:
```bash
apptainer help
```

```txt
Linux container platform optimized for High Performance Computing (HPC) and
Enterprise Performance Computing (EPC)

Usage:
  apptainer [global options...]

Description:
  Apptainer containers provide an application virtualization layer enabling
  mobility of compute via both application and environment portability. With
  Apptainer one is capable of building a root file system that runs on any
  other Linux system where Apptainer is installed.

Options:
      --build-config    use configuration needed for building containers
  -c, --config string   specify a configuration file (for root or
                        unprivileged installation only) (default
                        "/etc/apptainer/apptainer.conf")
  -d, --debug           print debugging information (highest verbosity)
  -h, --help            help for apptainer
      --nocolor         print without color output (default False)
  -q, --quiet           suppress normal output
  -s, --silent          only print errors
  -v, --verbose         print additional information
      --version         version for apptainer

Available Commands:
  build       Build an Apptainer image
  cache       Manage the local cache
  capability  Manage Linux capabilities for users and groups
  checkpoint  Manage container checkpoint state (experimental)
  completion  Generate the autocompletion script for the specified shell
  config      Manage various apptainer configuration (root user only)
  delete      Deletes requested image from the library
  exec        Run a command within a container
  help        Help about any command
  inspect     Show metadata for an image
  instance    Manage containers running as services
  key         Manage OpenPGP keys
  keyserver   Manage apptainer keyservers
  oci         Manage OCI containers
  overlay     Manage an EXT3 writable overlay image
  plugin      Manage Apptainer plugins
  pull        Pull an image from a URI
  push        Upload image to the provided URI
  registry    Manage authentication to OCI/Docker registries
  remote      Manage apptainer remote endpoints
  run         Run the user-defined default command within a container
  run-help    Show the user-defined help for an image
  search      Search a Container Library for images
  shell       Run a shell within a container
  sif         Manipulate Singularity Image Format (SIF) images
  sign        Add digital signature(s) to an image
  test        Run the user-defined tests within a container
  verify      Verify digital signature(s) within an image
  version     Show the version for Apptainer

Examples:
  $ apptainer help <command> [<subcommand>]
  $ apptainer help build
  $ apptainer help instance start

For additional help or support, please visit https://apptainer.org/help/
```
Based on the help documentation, here are the core commands we will cover in this guide, categorized by their role in the container lifecycle:

- `pull`: downloads a pre-built image from a remote registry (like Docker Hub) to your local system.
- `build`: creates a new image from a definition file (`*.def`) or converts an existing OCI source (like Docker) into a native SIF (Singularity Image Format) file
- `run`: launches the container and automatically executes the internal script defined in the `%runscript` section of the image
- `shell`: spawns an interactive terminal session inside the container. This is perfect for exploring the environment or debugging your setup
- `exec`: executes a specific, one-off command within the container without entering an interactive session or triggering the default runscript

Now, let's dive into each of these commands and see how they work in practice on an HPC cluster.

## 2. Pull and Build Images

### 2.1 Some key concepts

**Images**
The core concept in Apptainer is the container image, which is a self-contained file that includes an application and all its dependencies.

**Container**
A container is a runtime instance of an image. When you run an image, it creates a container that executes the application inside it.

## 2.2 Pulling Pre-built Images
Using Apptainer, you can pull pre-built images from Apptainer/Singularity Hub, [Docker Hub](https://hub.docker.com/), [AMD Infinity Hub](https://www.amd.com/en/developer/resources/infinity-hub.html), [NVIDIA NGC catalogs](https://catalog.ngc.nvidia.com/containers), or other OCI registries, or you can build your own custom images using definition files. 

You can use the `pull` command to download an image from a registry. For example, to pull the latest Alpine Linux image from Docker Hub:

```bash
apptainer pull docker://alpine
```
This will download the Alpine image and convert it into a SIF file named `alpine_latest.sif` in your current directory.

By using the `pull` command, you can also build a SIF image directly from an OCI source. For example, to build a SIF image named `lolcow.sif` from the lolcow image:

```bash
apptainer build lolcow.sif docker://ghcr.io/apptainer/lolcow
```

**Notes:**
- A SIF file is the standard Apptainer image format.
- On many clusters, pulling from the internet must be done on login/master nodes. The computation nodes may not have direct internet access.

## 3. Interacting with Containers

### 3.1 The `run` and `shell` commands

Now that you have an image, you can run it in different ways. Let's start with the `run` command. 

```bash
apptainer run lolcow.sif
```
This will execute the default command defined in the image's `%runscript`. In this case, it will print a colorful ASCII cow with the current date and time. You should see output similar to this:
```txt
 _____________________________
< Sat May 2 21:27:30 -03 2026 >
 -----------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

```	

We can jump into the container using the `shell` command which opens an interactive shell inside the container.

```bash
apptainer shell lolcow.sif
```
This will give you a shell prompt inside the container, allowing you to explore the filesystem, check installed software, and run commands interactively. For example, you can check the os-release file to see the base OS of the container:
```bash
cat /etc/os-release
```
You should see something like this:
```txt
Apptainer> cat /etc/os-release 
NAME="Ubuntu"
VERSION="20.04.2 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.2 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
Apptainer> 
```

As you can see, the base image (Ubuntu 20.04) is different from the host system. If you list files `ls` in the current directory, you will see the same files as on the host because Apptainer bind-mounts the current working directory by default. However, if you check for installed packages, you will see that the container has its own isolated environment. For example, if you check for `cowsay` (which is installed in the container but not on the host), you will see it is available inside the container:

```bash
dpkg -l | grep cowsay  # shows package entry if installed
cowsay "Hello from the container!"
```

### 3.2 The `exec` command

The `exec` command allows you to run a specific command inside the container without opening an interactive shell. For example, to run `cowsay` with a custom message:

```bash
apptainer exec lolcow.sif cowsay "Hello INF0090!"
```
This will print a cow saying "Hello INF0090!" without needing to enter the container shell.

```txt
 _______________________
< Hello INF0090! >
 -----------------------
		\   ^__^
		 \  (oo)\_______
		    (__)\       )\/\
		        ||----w |
		        ||     ||
```	

## 4. Build a Custom Container

You can also create your own custom container by writing a definition file that specifies the base image and the steps to set up the environment. For example, let's create a container that has `cowsay` and `lolcat` installed.

Create a file named `lolcow.def` with the following content:

```def
Bootstrap: docker
From: ubuntu:24.04

%post
	apt-get -y update
	apt-get -y install cowsay lolcat

%environment
	export LC_ALL=C
	export PATH=/usr/games:$PATH

%runscript
	date | cowsay | lolcat

%labels
	INF0090 - HPC and AI Course - Apptainer Basics
```

As you can see, this definition file uses the `docker` bootstrap to start from an Ubuntu 24.04 base image. The `%post` section contains the commands to install `cowsay` and `lolcat`. The `%environment` section sets environment variables that will be available inside the container. The `%runscript` section defines the default command that will run when you execute the container with `apptainer run`. Finally, the `%labels` section adds metadata to the image.

To build and run the container, use the following commands:

```bash
apptainer build mylolcow.sif lolcow.def
apptainer run mylolcow.sif
```

## 5. GPU Support

You can also run GPU-accelerated applications inside Apptainer containers. To do this, you need to use the appropriate flag for your GPU type when running the container, which exposes the GPU and its libraries to the container.

### 5.1 AMD GPU Support

For AMD GPUs, you can use the `--rocm` flag to expose AMD GPUs and ROCm libraries to the container. For example, to run `amd-smi` inside a ROCm container:

```bash
# Pull the latest ROCm development image from AMD Infinity Hub
apptainer pull amd_pytorch.sif docker://rocm/pytorch:rocm7.2.3_ubuntu24.04_py3.12_pytorch_release_2.9.1

# Run amd-smi inside the container with AMD GPU support
# Notice we are using `srun -p gpu` to run on a node with a GPU
srun -p gpu apptainer exec --rocm amd_pytorch.sif amd-smi
```

You should see output similar to this, which indicates that the container can access the AMD GPU:

```txt
+------------------------------------------------------------------------------+
| AMD-SMI 26.2.2+671d39a71e    amdgpu version: Linuxver ROCm version: 7.2.2    |
| VBIOS version: 020.040.000.042.000000                                        |
| Platform: Linux Baremetal                                                    |
|-------------------------------------+----------------------------------------|
| BDF                        GPU-Name | Mem-Uti   Temp   UEC       Power-Usage |
| GPU  HIP-ID  OAM-ID  Partition-Mode | GFX-Uti    Fan               Mem-Usage |
|=====================================+========================================|
| 0000:67:00.0         Instinct MI210 | 0 %      52 °C   0            42/300 W |
|   0       0     N/A             N/A | 5 %        N/A             10/65520 MB |
+-------------------------------------+----------------------------------------+
+------------------------------------------------------------------------------+
| Processes:                                                                   |
|  GPU        PID  Process Name          GTT_MEM  VRAM_MEM  MEM_USAGE     CU % |
|==============================================================================|
|  No running processes found                                                  |
+------------------------------------------------------------------------------+
```

**Verifying PyTorch GPU Acceleration**

To confirm that PyTorch can successfully communicate with the AMD hardware from within the container, run the following command. This uses `srun` to request a GPU node and `apptainer` to execute the check:

```bash
srun -p gpu --gres=gpu:1 apptainer exec --rocm \
  amd_pytorch.sif python3 -c 'import torch; print(f"PyTorch version: {torch.__version__}"); print(f"ROCm available: {torch.cuda.is_available()}"); print(f"ROCm version: {torch.version.hip}"); print(f"GPU count: {torch.cuda.device_count()}"); print(f"GPU name: {torch.cuda.get_device_name(0)}")'
```

If the setup is correct, you will see `ROCm available: True` and the specific name of the accelerator (e.g., AMD Radeon Graphics or gfx942):

```txt
PyTorch version: 2.9.1+rocm7.2.3.gitebc02d69
ROCm available: True
ROCm version: 7.2.53211-c2d9476115
GPU count: 1
GPU name: AMD Radeon Graphics
``` 

You can modify the above command to use two GPUs by changing `--gres=gpu:1` to `--gres=gpu:2` and check the output of `torch.cuda.device_count()` and `torch.cuda.get_device_name(i)` for each GPU index.


### 5.2 NVIDIA GPU Support

For NVIDIA GPUs, you can use the `--nv` flag to expose NVIDIA GPUs and CUDA libraries to the container. For example, to run `nvidia-smi` inside a CUDA container:

```bash
# Pull the CUDA 12.8 base image from Docker Hub
apptainer pull docker://nvidia/cuda:12.8.0-base-ubuntu20.04

# Run nvidia-smi inside the container with NVIDIA GPU support
apptainer exec --nv cuda_12.8.0-base-ubuntu20.04.sif nvidia-smi
```

You should see output similar to this, which indicates that the container can access the NVIDIA GPU:

```txt   
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 565.57.01              Driver Version: 565.57.01      CUDA Version: 12.7     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla P100-PCIE-12GB           Off |   00000000:65:00.0 Off |                    0 |
| N/A   46C    P0             33W /  250W |       0MiB /  12288MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

## 6. Apptainer with Slurm

On HPC clusters, you typically run Apptainer containers within Slurm jobs. In a similar way we did in the [Slurm tutorial](../../01-hpc-intro/3-slurm-basics/README.md) you can create a Slurm script that executes Apptainer containers. For example, we will create a Python script that uses PyTorch to make some computations on the GPU. First, create a file named `pytorch_gpu.py` with the following content:

```python
import torch
import torch.nn as nn
import torch.nn.functional as F
import time

# 1. Define a tiny CNN 
class TinyNet(nn.Module):
    def __init__(self):
        super(TinyNet, self).__init__()
        self.conv1 = nn.Conv2d(3, 16, kernel_size=3, padding=1)
        self.fc = nn.Linear(16 * 32 * 32, 10)

    def forward(self, x):
        x = F.relu(self.conv1(x))
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        return x

# 2. Setup Device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using GPU: {torch.cuda.get_device_name(0)}")

# 3. Initialize Model and Data
model = TinyNet().to(device)
dummy_input = torch.randn(64, 3, 32, 32).to(device) # Batch of 64 images

# 4. Inference
print("Running forward pass...")
start_time = time.time()
with torch.no_grad():
    output = model(dummy_input)
end_time = time.time()

print(f"Success! Output shape: {output.shape}")
print(f"Memory used on HBM3: {torch.cuda.memory_reserved(0) / 1024**2:.2f} MB")
print(f"Execution time: {end_time - start_time:.4f} seconds")
```

Then, you can create a Slurm script named `run_pytorch_gpu.sh` to execute this Python script inside the `amd_pytorch.sif` container on a GPU node:

```bash
#!/bin/bash
#SBATCH --job-name=apptainer_pytorch_gpu
#SBATCH --output=apptainer_pytorch_gpu.out
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

srun apptainer exec amd_pytorch.sif python3 pytorch_gpu.py
```
Then, you can submit the job with `sbatch run_pytorch_gpu.sh` and check the output in `apptainer_pytorch_gpu.out` once the job finishes. You should see output similar to this, confirming that the container can access the GPU and run PyTorch computations:

```txt
Using GPU: AMD Instinct MI300X
Running forward pass...
Success! Output shape: torch.Size([64, 10])
Memory used on HBM3: 98.00 MB
Execution time: 2.4741 seconds
```

You can also create an interactive session using the `srun --pty` command to execute Apptainer commands on compute nodes. For example, the same `amd_pytorch.sif` container in an interactive Slurm session will look like this:

```bash
srun --pty -p gpu --gres=gpu:1 apptainer shell amd_pytorch.sif
```

## 7. Cache Management

Apptainer stores pulled and built images in a local cache directory (usually `~/.apptainer/cache`). Over time, this cache can grow and consume a lot of disk space. You can manage the cache with the `cache` command. For example, to list the contents of the cache:

```bash
apptainer cache list
# To see more details, use the verbose flag
apptainer cache list -v

```

To clean the cache and remove all cached images, use:

```bash
apptainer cache clean
# To remove only images that are older than 15 days, use the --days flag
apptainer cache clean --days 15
```

Regular cache cleanup is important on quota-limited systems.

## Further Reading

- Apptainer official docs: https://apptainer.org/docs/
- Apptainer quick start: https://apptainer.org/docs/user/main/quick_start.html
- Apptainer definition files: https://apptainer.org/docs/user/main/definition_files.html
- Apptainer GPU support: https://apptainer.org/docs/user/latest/gpu.html
