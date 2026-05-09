# Sending jobs with Slurm

This tutorial shows how to submit, monitor, and cancel jobs with Slurm in INFO090. We will cover writing simple batch scripts, requesting resources, and running parallel jobs. By the end, you will understand how to use Slurm to run your computations on the cluster effectively.

## Quick Cheat Sheet

| Task | Command |
|---|---|
| Check Slurm partitions | `sinfo` |
| Submit a job script | `sbatch job.sh` |
| Check your jobs | `squeue -u $USER` |
| Cancel one job | `scancel <jobid>` |
| Cancel all your jobs | `scancel -u $USER`  or  `scancel --me` |
| Check job efficiency | `seff <jobid>` |
| Open interactive compute shell | `srun --pty bash` |

## Why Slurm?
On HPC clusters, many users share many nodes. Slurm is the scheduler that decides where and when jobs run, based on requested resources.

## 1. Check partitions with sinfo

Before submitting jobs, it's useful to know what resources are available on the cluster. The `sinfo` command shows you all available partitions (queues) and their status.

**Checking available partitions with sinfo**

To see all partitions and their current status, run:

```bash
sinfo
```

This will show you output like:

```
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
cpu*         up 1-00:00:00      4   idle n[1-4]
gpu          up 1-00:00:00      1   idle g1
```

The columns show:
- `PARTITION`: the name of the partition
- `AVAIL`: whether the partition is available (`up` or `down`)
- `TIMELIMIT`: maximum job runtime allowed
- `NODES`: total number of nodes in the partition
- `STATE`: node state (`idle`, `alloc`, `down`, etc.)
- `NODELIST`: which nodes are in that partition

You can also get more detailed information about a specific partition:

```bash
sinfo -p cpu
```

Or see detailed node information:

```bash
sinfo -N -l
```

## 2. Your first program with srun

Now that you know what resources are available, let's run a simple program on a compute node. `srun` launches a command directly on compute nodes allocated by Slurm, without needing to create a batch script. This is useful for quick tests or running parallel programs.

```bash
srun bash -c 'echo "Hello world from node $(hostname)!"'
```

**What is happening here?**

* **`srun`**: Requests a resource allocation from Slurm and executes the following command.
* **`bash -c`**: Opens a Bash shell instance inside the allocated compute node to interpret the command.
* **Single Quotes (`' '`)**: These are crucial. They prevent your local terminal (the login node) from expanding `$(hostname)`. By using single quotes, the command is sent "as is" to the compute node, ensuring the hostname displayed is the one from the execution node.
* **Result**: You will see a message like `Hello world from node node-1.novalocal`. The name will vary depending on which node Slurm has assigned to your job.

> **Pro Tip:** Try running the command again adding `-n 2` before `bash`. You will see Slurm launch the command in two simultaneous instances, demonstrating the start of parallel execution!


## 3. Your first batch job script

In Slurm, there are two main ways to run jobs: direct execution with `srun` (which we just tried) and batch jobs with `sbatch`. Batch jobs are better for actual computations because they can be queued and managed by the scheduler. Let's create your first batch job.

Log in to the cluster and create a file named `example-job.sh`:

```bash
#!/bin/bash
#SBATCH -J hello-world      # Job name
#SBATCH -p cpu              # Partition (queue)
#SBATCH -N 1                # Number of nodes
#SBATCH -n 1                # Number of tasks
#SBATCH -t 00:01:00         # Walltime (hh:mm:ss)

echo -n "This script is running on "
hostname
echo "I will sleep for 10 seconds so you can see me in the queue..."
sleep 10
```
This script requests 1 CPU for 1 minute and prints the hostname of the compute node it runs on. To submit it, run:

```bash
sbatch example-job.sh
```
This will launch the job and return a `<jobid>`. You can check the status of your jobs with:

```bash
squeue --me
```
- if you see a job with status `R`, it means it is running. 
- if it is `PD`, it is pending and waiting for resources. 

Once the job finishes, its output will be saved in a file named `slurm-<jobid>.out` in the same directory as your script. You can check the output with:

```bash
cat slurm-<jobid>.out
```

## 4. Customizing your job script

Now that you have successfully submitted a job, you can customize your resource requests. Slurm uses `#SBATCH` directives at the top of the script to communicate with the scheduler. Here are the most common options:

| Directive | Description | Example |
| --- | --- | --- |
| `-n <ntasks>` | Total number of tasks (usually 1 per CPU core) | `-n 4` |
| `-N <nnodes>` | Total number of physical nodes requested | `-N 1` |
| `-t <HH:MM:SS>` | Maximum time the job is allowed to run (Walltime) | `-t 00:10:00` |
| `--mem=<size>` | Total memory per node (e.g., K, M, G) | `--mem=4G` |
| `-p <partition>` | The queue/partition to use | `-p cpu` or `-p gpu` |
| `-J <name>` | A custom name for your job (visible in `squeue`) | `-J my_experiment` |
| `-o <file>` | Standard output file (default: `slurm-<jobid>.out`) | `-o output.log` |
| `-e <file>` | Standard error file (default: merged with stdout) | `-e error.log` |


**Example: Requesting Multiple CPUs**

To request **4 CPUs** and **2 GB of memory** for **10 minutes**, create a file named `example-multiple-cpu.sh` with the following content:

```bash
#!/bin/bash
#SBATCH -J multi-cpu-test
#SBATCH -p cpu
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem=2G
#SBATCH -t 00:10:00

echo "This script is running on $(hostname)"
echo "Slurm has allocated $SLURM_NTASKS tasks for this job."
```

Submit it using `sbatch example-multiple-cpu.sh`. Once finished, check your `.out` file to verify the number of tasks.

### 4.1 Customizing Output and Error Files

By default, Slurm merges both standard output (**stdout**) and standard error (**stderr**) into a single file named `slurm-<jobid>.out`. To keep your workspace organized and make debugging easier, you can use the `-o` and `-e` directives to separate these streams into different files.

Create a file named `example-custom-output.sh`:

```bash
#!/bin/bash
#SBATCH -J output-test
#SBATCH -p cpu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 00:05:00
#SBATCH -o output_test_%j.out    # Standard output (%j expands to the Job ID)
#SBATCH -e output_test_%j.err    # Standard error

echo "This message will be sent to the .out file (stdout)"
echo "This error message will be sent to the .err file (stderr)" >&2
```

Submit the job as usual:

```bash
sbatch example-custom-output.sh
```

Once the job finishes, verify the contents of both files:

```bash
cat output_test_<jobid>.out    # View successful execution logs
cat output_test_<jobid>.err    # View error messages and warnings

```

**Common Filename Patterns:**

* **`%j`**: Expands to the Job ID (e.g., `12345`). This is highly recommended to prevent jobs from overwriting each other's logs.
* **`%x`**: Expands to the Job Name (e.g., `output-test`).
* **`/dev/null`**: If you want to discard output entirely (e.g., `#SBATCH -o /dev/null`), though this is usually only done for stable, high-volume production jobs.

### 4.2 Using Modules in your job script

Since most software in HPC environments is managed via **Environment Modules**, you must load the required software inside your script before executing any commands.

Create a new script named `python-job.sh`:

```bash
#!/bin/bash
#SBATCH -J python-job
#SBATCH -p cpu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 00:05:00
#SBATCH -o python-job-%j.out

# 1. Load the Python module
# (Make sure to use the exact version available on the cluster)
module load python/3.13.1

# 2. Verify the environment (good practice for debugging)
echo "Using python from: $(which python3)"
python3 --version

# 3. Run your code
python3 -c "import socket; print('Hello from Python on node:', socket.gethostname())"

```

Submit it with:

```bash
sbatch python-job.sh

```

## 5. Run an interactive job

For development and testing, you can also run interactive jobs that give you a direct shell on a compute node. This is useful for debugging and trying out commands before putting them in a batch script. To start an interactive session, run:

```bash
srun --pty bash
```

You can customize the resource requests for the interactive session as well, using the same `--ntasks`, `--nodes`, `--time`, etc. options. For example:

```bash
srun --pty -n 4 --time=00:10:00 bash
```
This will give you a shell with 4 tasks for 10 minutes. You can run commands interactively, and when you exit the shell, the session will end. For example, I will create an interactive session, load a Python module, and run a Python command:

```bash
# Start interactive session with 1 task and 5 minutes
srun --pty -n 1 --time=00:05:00 bash

## Inside the interactive shell
module load python/3.13.1
python3 -c "import socket; print('Hello from Python on', socket.gethostname())"
```

## Further reading

- Scheduler Fundamentals: https://carpentries-incubator.github.io/hpc-intro/13-scheduler.html
- Slurm documentation: https://slurm.schedmd.com/documentation.html
