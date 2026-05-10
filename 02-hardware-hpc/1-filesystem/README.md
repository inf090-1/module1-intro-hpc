# Understanding the HPC Cluster Filesystem

When you use your personal computer, all your files (system files, documents, downloads) usually live on a single hard drive. In a High-Performance Computing (HPC) cluster, storage works very differently.

Because hundreds of users are running thousands of jobs simultaneously, the cluster uses a **network-mounted filesystem**. This means the storage drives are physically separate from the compute nodes but are connected via a high-speed network.

To manage cost, speed, and safety, HPC centers divide this storage into different "tiers" or directories. Knowing where to put your data is critical for your job's performance and the cluster's health.

## Where should your files go?

### The Home Directory (`$HOME`)

When you log into the cluster, you land in your Home directory.

* **Best for:** Source code, compilation scripts, Python virtual environments, and small configuration files.
* **Warning:** Never read or write massive datasets from your Home directory while a job is running. It is not designed for heavy I/O (Input/Output) and doing so can slow down the login nodes for everyone.

### The Scratch Directory (`$SCRATCH`)

This is the workhorse of the cluster. It is built using parallel, high-speed storage systems designed to handle massive amounts of data being read and written by thousands of CPUs at once.

* **Best for:** Active job inputs, massive datasets, machine learning training data, and job output files.
* **Warning:** Scratch is **never backed up**. Furthermore, most HPCs have an automated purge policy (e.g., files older than 30 days are automatically deleted). Once your job is done, move the important results back to your Home or Project folder.

### Local Node Storage (`/tmp`)
Compute nodes often have a small, physical hard drive (usually an SSD) installed directly inside them.

* **Best for:** Extremely temporary files that your program needs to read/write millions of times per second.
* **Warning:** This drive is entirely local to that specific compute node. When your Slurm job finishes, the `/tmp` directory is wiped clean.

## Exploring your storage space

Let's look at a few commands to help you navigate and understand this network storage. 

Run these in your terminal to check the paths to your `$HOME` and `$SCRATCH` directories:

```bash
echo $HOME
echo $SCRATCH
```

You will see an output like:

```text
/home/info090/yourUsername
/scratch/yourUsername
```

Now, let's create an interactive job to jump onto a compute node and execute the exact same commands:

```bash
# Create an interactive job
srun --pty bash 

# Check your variables again
echo $HOME
echo $SCRATCH
```

You will notice that the paths to your `$HOME` and `$SCRATCH` directories remain identical, even though you’ve hopped onto a completely different physical machine. How is this possible? The magic lies in the **Network Filesystem (NFS)**, which "mounts" the same storage drives across the entire cluster. To see this invisible network in action, use the `df -h` (disk free) command while still in your interactive job.

### Understanding the Network Mounts

When you run `df -h` on a compute node, the output reveals the "plumbing" of the cluster:

```text
Filesystem                Size  Used Avail Use% Mounted on
devtmpfs                  4.0M     0  4.0M   0% /dev
tmpfs                     3.8G   12K  3.8G   1% /dev/shm
tmpfs                     1.6G  592K  1.5G   1% /run
/dev/vda4                  24G  3.2G   21G  14% /
/dev/vda3                 936M  508M  429M  55% /boot
/dev/vda2                 100M   11M   90M  11% /boot/efi
headnode:/home            249G   34G  215G  14% /home
headnode:/opt/ohpc/pub    249G   34G  215G  14% /opt/ohpc/pub
headnode:/scratch         249G   34G  215G  14% /scratch
headnode:/opt/ohpc/admin  249G   34G  215G  14% /opt/ohpc/admin
```

Look closely at the `Filesystem` column for the last four rows. Notice the prefix **`headnode:`**. In Linux, this notation means: *"This directory isn't physically on this machine; it is being served by the machine named **headnode**."*

#### Beyond just /home and /scratch*

You’ll notice that `/home` and `/scratch` aren't the only travelers on the network. Folders like `/opt/ohpc/pub` and `/opt/ohpc/admin` are also mounted from the headnode. **Why?** This ensures that every compute node has access to the exact same compilers, MPI libraries, and software tools. If the admin installs a new version of Python in `/opt/ohpc/pub` on the headnode, it instantly appears on every compute node in the cluster.

#### The View from the Headnode

If you exit your interactive job and run `df -h` on the **headnode**, the output changes significantly. On the headnode, these aren't "network mounts", they are local partitions. You won't see the `headnode:` prefix because the headnode *is* the source. It "exports" these directories to the rest of the cluster so that no matter where your code runs, it feels like you never left home.

```
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        4.0M     0  4.0M   0% /dev
tmpfs           3.8G     0  3.8G   0% /dev/shm
tmpfs           1.5G  8.7M  1.5G   1% /run
/dev/vda4       249G   34G  215G  14% /
/dev/vda3       936M  508M  429M  55% /boot
/dev/vda2       100M   11M   90M  11% /boot/efi
tmpfs           768M  4.0K  768M   1% /run/user/10001
tmpfs           768M  4.0K  768M   1% /run/user/11000
tmpfs           768M  4.0K  768M   1% /run/user/1000
```

#### What about the `/tmp` folder?

You might have noticed that `/tmp` does not appear as a separate line in your `df -h` output. This is because, on this cluster, `/tmp` is not its own unique storage device, it is simply a folder living inside the local **Root (/)** partition of the node.

Unlike `$HOME` or `$SCRATCH`, which are shared across the network, `/tmp` is **node-local**. This means every machine has its own private version of `/tmp`. You can verify this by comparing the contents of the headnode's temporary folder with a compute node's folder:

```bash
## List /tmp files on the headnode
ls /tmp

## List /tmp files on a compute node
srun ls /tmp
```
Node-local storage is incredibly fast because the data doesn't have to travel over the network cables. However, it is **ephemeral**.

## The Golden Rules of HPC Storage

Managing files on a cluster isn't just about organization—it’s about performance. Following these rules ensures your jobs run faster and you don't accidentally lose weeks of work.

* **Code in `$HOME`, Data in `$SCRATCH`**: Think of `$HOME` as your safe, permanent library and `$SCRATCH` as your high-speed workshop. Always compile your code and keep your scripts in `$HOME`, but point your simulation's large input and output paths to `$SCRATCH`.
* **Treat `/tmp` as a "Short-lived Workspace"**: Use the local `/tmp` directory for high-speed, temporary files that your program needs to "write and discard" quickly.
  * **Warning:** Always copy any important results from `/tmp` to `$SCRATCH` before your script finishes. Once the job ends, that node's local storage is cleared, and your data is gone forever.
* **Avoid the "Small File Problem"**: Parallel filesystems (like those powering `$SCRATCH`) are designed for massive throughput, not high-frequency "metadata" checks. Reading one 10GB file is significantly faster than reading 10,000 files that are 1MB each.
* **Scratch is not a Backup**: If your results are in `$SCRATCH`, assume they are at risk. Between automated "purge" policies (which delete old files to make room for others) and the lack of backups, `$SCRATCH` is for *work in progress* only.
