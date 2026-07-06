# Checking on running jobs

### Checking on the status of your job:

If you would like to check the status of your job, you can use the `squeue` command to do so. Typing `squeue` without any options will output all currently running or queued jobs to your terminal window, but there are many options to help display relevant information. To find more of these options, type `man squeue` when logged in to a CARC machine. To see which jobs are running and queued in the standard output, type the following in a terminal window:

```bash
squeue
```
```
 JOBID  PARTITION     NAME     USER   ST  TIME  NODES NODELIST(REASON)
 155161  bigmem       job1     usr1 PD  0:00      1  (Resources)
 155071  bigmem       job2     usr2  R  17:17:00  1  easley050
 155068  bigmem       job3     usr3  R  17:29:37  1  easley050
 152827  debug        job4     usr4 PD  0:00      1  (PartitionTimeLimit)
```

The output of `squeue` shows the job ID, partition, job name, job owner, job status (such as pending (PD) or running (R)), the number of nodes allocated, and either the reason a job is pending or the names of the nodes on which a job is running. To view a specific job in the queue without listing every running job, you can use the job ID with `squeue -j <jobID>`, or you can filter by user with `squeue -u <username>`. Additionally, you can use `squeue --me` to view only your own jobs.

For example:
```bash
squeue -j 155161
```
```
JOBID PARTITION   NAME   USER   ST   TIME  NODES NODELIST(REASON)
155161  bigmem    job1   user1  PD   0:00    1    (Resources)
```

A useful Slurm option is `squeue -l`, which displays more detailed job information than `squeue` alone; in addition to the standard fields, it includes requested resources such as nodes, tasks, memory, wall-time limits, and the job's actual runtime.

The `scontrol show job <jobID>` command provides a "full" display of information about a job. It shows details such as the job name, owner, CPU time, memory usage, walltime, job status, paths to output and error files, executing nodes, core allocation, and other relevant information.

`watch squeue -u <username>` provides an interactive, continuously updating view of that user's jobs, refreshing every 2 seconds.

### Determining which nodes your job is using:

If you would like to check which nodes your job is using, you can pass the `-j` option to `squeue`. When your job is finished, your processes on each node will be killed by the system, and the node will be released back into the available resource pool.

```bash
squeue -j 156510
```
```
 JOBID PARTITION     NAME     USER   ST     TIME  NODES NODELIST(REASON)
 156510   l40s     interact    usr   R       2:02     1   easley056
```

Here, the node this job is running on is easley056.

### Checking job resource utilization with `jobeff` and `seff`

Once you know a job is running, it's worth checking whether it's actually using the CPU, memory, and GPU resources you requested — over-requesting wastes your queue time and shared cluster capacity, while under-requesting risks the job running out of memory. Easley provides two commands to compare requested vs. actual usage.

For a currently running job, use `jobeff` to compare real-time CPU and memory utilization against your Slurm allocation. Run it with no arguments to see all of your currently running jobs:

```bash
jobeff
```

```
[##############################] 100% (1/1) Done

 [###############               ]  50% (1/2) Round 1/1: your_username (6 pids on 1 node

[##############################] 100% (2/2) Done
Samples: 1 completed as a single sample using a 5s window.
NODE          USER          PARTITIONS          JOBS  ALLOC_CPU   BUSY_CPU   CPU_EFF%  ALLOC_GPU  GPU_PROCS      VRAM%   ALLOC_MEM          MEM_USED   MEM_EFF%     PROCS          LOCAL_IO            NET_IO
easley0XX     your_username l40s                   1       16.0       0.22        1.4        1.0          0        0.0    32.0 GiB         560.4 MiB        1.7         5         2.5 MiB/s         6.1 MiB/s
```

The same output, broken out for readability:

| Field | Value | Meaning |
|---|---|---|
| Node | `easley0XX` | Node the job is running on |
| Partition | `l40s` | GPU partition used |
| Allocated CPUs | 16.0 | CPUs requested |
| Busy CPUs | 0.22 | CPUs actually in use |
| **CPU Efficiency** | **1.4%** | Busy ÷ allocated CPU |
| Allocated GPUs | 1.0 | GPUs requested |
| GPU Processes | 0 | Processes currently using the GPU |
| VRAM Usage | 0.0% | GPU memory in use |
| Allocated Memory | 32.0 GiB | Memory requested |
| Memory Used | 560.4 MiB | Memory actually in use |
| **Memory Efficiency** | **1.7%** | Used ÷ allocated memory |
| Processes | 5 | Active process count |
| Local I/O | 2.5 MiB/s | Disk read/write rate |
| Network I/O | 6.1 MiB/s | Network transfer rate |

In this example, the job requested 16 CPUs but is only using a small fraction of that (`CPU_EFF%` of 1.4) and barely touching its 32 GiB memory allocation (`MEM_EFF%` of 1.7) — a sign that future submissions of this job could likely request far fewer resources.

Once a job has finished, use `seff` to get the same kind of comparison for the completed run:

```bash
seff <jobID>
```

```
Job ID: <jobID>
Cluster: easley
User/Group: your_username/your_username
State: COMPLETED (exit code 0)
Nodes: 1
Cores per node: 16
CPU Utilized: 00:01:10
CPU Efficiency: 8.41% of 00:13:52 core-walltime
Job Wall-clock time: 00:00:52
Memory Utilized: 4.34 GB
Memory Efficiency: 13.57% of 32.00 GB (32.00 GB/node)
```

Here too, the job finished using only 8.41% of its requested CPU time and 13.57% of its requested memory — both strong indicators that the next submission of this job could request fewer cores and less memory, freeing up those resources for other jobs (including your own) and likely reducing queue wait times.

Both commands are useful for catching allocation vs. usage mismatches — for example, requesting 16 CPUs but only using 2, or requesting far more memory than the job ever touches. Adjusting future job submissions based on this feedback helps your jobs queue faster and leaves more resources available for other users.

### Viewing output and error files:

Once your job has completed, you should see two files in the directory from which you submitted the job: an output file and an error file, named `slurm-JobID.out` and `slurm-JobID.err` (where `JobID` refers to the ID of the job returned by `sbatch`).

For the example job above, these two files would be named `slurm-155161.out` and `slurm-155161.err`, respectively.

Any output from the job sent to "standard output" will be written to the output file, and any output sent to "standard error" will be written to the error file. The amount of information in the output and error files varies depending on the program being run and how the `sbatch` batch script was set up.

*This quickbyte was validated on 6/22/2026*
