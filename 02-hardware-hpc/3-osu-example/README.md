# Assessing inter-node performance with OSU microbenchmarks

In the [previous guides](../01-hpc-intro/README.md) you learned the basics for accessing a cluster, transferring files, and running simple MPI programs. In this guide, we will use all learned  skills to assess the inter-node communication performance of a cluster using the OSU microbenchmarks suite. These benchmarks are widely used in HPC to measure latency and bandwidth of MPI communication. 

## Preliminaries
- Log in to the INFO090 cluster
- Complete the [01-hpc-intro](../01-hpc-intro/README.md) guides to understand the basics of cluster access, file transfer, and job submission.


## 1. Verify binaries and environment

Load the OSU microbenchmarks and MPICH modules:

```bash
module load omb
module load mpich
```

Now, to ensure the `osu_latency` and `osu_bw` binaries are available:

```bash
which osu_latency osu_bw
```

You should see the paths to these executables.

```txt
/opt/ohpc/pub/libs/gnu14/mpich/omb/7.5/bin/osu-micro-benchmarks/mpi/pt2pt/osu_latency
/opt/ohpc/pub/libs/gnu14/mpich/omb/7.5/bin/osu-micro-benchmarks/mpi/pt2pt/osu_bw
```
## 2.  Run an inter-node latency test

We will use the [OSU Latency Benchmark](https://mvapich.cse.ohio-state.edu/benchmarks/) to measure inter-node latency over Ethernet. This test places one MPI rank on two separate physical nodes and measures the "round-trip" time of data packets between them, providing a real-world comparison of network performance.

Create a Slurm submission script `submit_osu_latency.sh` with the following content:

```bash
#!/bin/bash
#SBATCH --job-name=osu-latency
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --output=osu_latency.out

module load mpich || true
module load omb || true

# Ethernet
echo "Running on Ethernet..."
mpirun -np 2 osu_latency
```

Submit the job with `sbatch submit_osu_latency.sh`. When the job completes you will have a `osu_latency.out` file with the results.

```txt
Running on Ethernet...

# OSU MPI Latency Test v7.5
# Datatype: MPI_CHAR.
# Size       Avg Latency(us)
1                     193.15
2                     176.01
4                     172.18
8                     196.05
16                    185.23
32                    170.97
64                    168.64
128                   180.13
256                   210.86
512                   232.69
1024                  234.99
2048                  201.93
4096                  207.26
8192                  347.32
16384                 383.89
32768                 575.56
65536                1204.28
131072               1811.91
262144               2974.59
524288               5303.51
1048576              9954.67
2097152             19163.91
4194304             37622.38
```

The latency for small messages (1 byte) is around 49 microseconds on Ethernet. As message size increases, the latency also increases. This represents the performance of inter-node communication over standard Ethernet.

## 3. Run an inter-node bandwidth test

Now, let's measure the bandwidth (the maximum rate at which data can be transferred across the network) using the `osu_bw` benchmark. While **latency** measures the "delay" of a single packet, **bandwidth** represents the total "throughput" or capacity of the data pipe.

Create a Slurm submission script `submit_osu_bandwidth.sh` with the following content:

```bash
#!/bin/bash
#SBATCH --job-name=osu-bandwidth
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --output=osu_bw.out

module load mpich || true
module load omb || true

# Ethernet
echo "Running on Ethernet..."
mpirun -np 2 osu_bw
```

Submit the job with `sbatch submit_osu_bandwidth.sh`. When the job completes you will have a `osu_bw.out` file with the results.

```txt
Running on Ethernet...

# OSU MPI Bandwidth Test v7.5
# Datatype: MPI_CHAR.
# Size      Bandwidth (MB/s)
1                       0.12
2                       0.25
4                       0.51
8                       1.03
16                      1.54
32                      3.42
64                      7.05
128                    12.57
256                    23.28
512                    39.41
1024                   56.73
2048                   78.75
4096                   92.04
8192                  100.07
16384                 106.49
32768                 109.92
65536                 110.51
131072                112.03
262144                112.82
524288                113.10
1048576               113.41
2097152               113.49
4194304               113.56
```

This output shows the bandwidth performance of Ethernet for inter-node communication. For a 4 MB message size, Ethernet achieves a throughput of approximately 936 Mbps (117 MB/s).

## 4. What about single-node performance?

To isolate the impact of the network, you can also run the same benchmarks on a single node (using shared memory communication) and compare the results to the inter-node runs. This will help you understand how much of the latency and bandwidth is due to the network versus other factors like CPU or memory performance.

Create a Slurm submission script `submit_osu_single_node.sh` with the following content:

```bash
#!/bin/bash
#SBATCH --job-name=osu-single-node
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --output=osu_single_node.out

module load mpich || true
module load omb || true

echo "Running on single node..."
mpirun -np 2 osu_latency
mpirun -np 2 osu_bw
```

Submit the job with `sbatch submit_osu_single_node.sh`. When the job completes you will have a `osu_single_node.out` file with the results for both latency and bandwidth on a single node.

```txt
Running on single node...

# OSU MPI Latency Test v7.5
# Datatype: MPI_CHAR.
# Size       Avg Latency(us)
1                       0.35
2                       0.35
4                       0.35
8                       0.35
16                      0.36
32                      0.36
64                      0.38
128                     0.61
256                     1.28
512                     1.36
1024                    1.56
2048                    1.57
4096                    3.31
8192                    4.71
16384                   7.44
32768                  12.13
65536                  18.45
131072                 32.77
262144                 56.75
524288                 92.85
1048576               179.41
2097152               350.09
4194304               710.92

# OSU MPI Bandwidth Test v7.5
# Datatype: MPI_CHAR.
# Size      Bandwidth (MB/s)
1                       4.73
2                       9.33
4                      19.22
8                      37.90
16                     74.69
32                    147.81
64                    177.43
128                   243.38
256                   403.39
512                   867.72
1024                 1442.38
2048                 2330.36
4096                 2212.12
8192                 3192.97
16384                4278.17
32768                4988.70
65536                5283.19
131072               5332.35
262144               5418.78
524288               5459.85
1048576              6024.89
2097152              6425.57
4194304              6508.68

```

These results show that on a single node, the latency is much lower (sub-microsecond) and the bandwidth is much higher (several GB/s) compared to the multi-node Ethernet runs. This clearly demonstrates that the network is the primary bottleneck for inter-node communication.

## 5. Multiple trials and detailed analysis

Now you have the tools to run the benchmarks repeatedly and produce robust visualizations and statistics. To do so we have provided an all-in-one submission script [submit_all_osu.sh](scripts/submit_all_osu.sh) that runs three trials for each configuration, and saves raw outputs into a results directory.

Execute the `submit_all_osu.sh` script with:

```bash
bash scripts/submit_all_osu.sh
```

The submitted jobs may take some time to complete because it runs several trials. You can monitor the job status with `squeue`. When the job finishes, you can use the `aggregate_osu_results.py` script to process the results.

To aggregate latency results and generate a plot, run:

```bash
# Activate the Python environment if you haven't already
source osu-env/bin/activate
python3 scripts/aggregate_osu_results.py --type latency
```

This command reads the latency files in the results directory, computes mean/std/min/max across trials per message size, and writes a comparison plot and a CSV summary into the same results directory.

![Latency Comparison](img/aggregated_latency_comparison.png)

As you can see from the plot, the single-node latency is significantly lower than the multi-node Ethernet configuration. 

Now, to aggregate bandwidth results and generate a plot, run:

```bash
python3 scripts/aggregate_osu_results.py --type bandwidth
```
![Bandwidth Comparison](img/aggregated_bw_comparison.png)

As expected, single-node performance serves as the upper bound for speed, as it leverages on-node shared memory. The multi-node Ethernet configuration shows significantly reduced bandwidth, which illustrates the limitations of standard Ethernet for bandwidth-intensive HPC applications.

**Performance Comparison Summary**

| Configuration | Latency (Small Msg) | Bandwidth (Large Msg) | Primary Data Path |
|---|---|---|---|
| Single-Node | ~0.3-0.5 µs | ~6-8 GB/s | Shared Memory (L3 Cache/RAM) |
| Multi-Node Ethernet | ~49-55 µs | ~110-120 MB/s | TCP/IP Stack over Copper/Fiber |




**Practical implications:**

- **Understanding the overhead**: The 100x increase in latency and 50-60x reduction in bandwidth when moving from single-node to multi-node Ethernet highlights the network overhead. For tightly-coupled parallel algorithms, this overhead will cause CPUs to sit idle while waiting for inter-node communication, limiting scalability.
- **Workload suitability**: Applications with high communication requirements will see significant performance penalties on standard Ethernet. Looser coupling or applications that communicate infrequently will be more suitable for Ethernet-based clusters.
- **Performance optimization**: When working with Ethernet interconnects, optimizing communication patterns and reducing message frequency become critical to achieving acceptable scaling efficiency.
