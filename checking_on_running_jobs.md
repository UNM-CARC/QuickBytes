# Managing software modules

### Modules

There are many software packages installed on CARC systems, as well as standard built-in functions native to Unix. To manage these additional software packages, CARC systems use modules. These modules set the appropriate environment variables and dependencies for software optimization and to avoid conflicts with other software.

For more information, visit [this page](https://lmod.readthedocs.io/en/latest/010_user.html), or use the command `module help`.

### Using modules to set application environments

Modules are used to set environment variables and dependencies for the purpose of managing access to applications and libraries on CARC systems. The command `module avail` lists all the modules available on the system you are logged in to. Note that this list can be extremely long — if you'd like to stop it from printing, use Ctrl+C (this works the same way on Mac, Windows, and Linux terminals, since you're connected to a remote Linux system either way).

To load a module, use the `module load` command. For example, to load the module for the Intel compiler, use the command:

```bash
module load intel
```

Another useful command related to module management is `module spider`. For example, if you issue the command:

```bash
module spider intel
```

you will see output similar to:

```
--------------------------------------------------------------------------------------------------------------------
  intel:
--------------------------------------------------------------------------------------------------------------------
     Versions:
        intel/18.0.4
        intel/19.0.5
        intel/20.0.4
     Other possible modules matches:
        intel-mkl  intel-mpi  intel-oneapi-compilers  intel-oneapi-mkl  intel-oneapi-mpi  intel-oneapi-runtime  ...
--------------------------------------------------------------------------------------------------------------------
  To find other possible module matches, execute:
      $ module -r spider '.*intel.*'
--------------------------------------------------------------------------------------------------------------------
  For detailed information about a specific "intel" package (including how to load the module), use the module's full name.
  Note that names with a trailing (E) are extensions provided by other modules.
  For example:
     $ module spider intel/20.0.4
--------------------------------------------------------------------------------------------------------------------
```

This command returns much more detailed information about a module of interest. You can see that there are actually multiple versions of the Intel compilers available for use, as is the case for most software installed on CARC systems.

To see all currently loaded modules, use the command `module list`. As an example, let's load the software modules for OpenMPI and GCC, then use `module list`:

```bash
module load openmpi gcc
```

```bash
module list
```

```
Currently Loaded Modules:
  1) miniconda3/latest             3) gcc/14.2.0-j33x             5) openmpi/4.1.7-762w
  2) binutils/2.43.1-ifi2qjn (H)   4) openssh/9.9p1-d4o73h6 (H)
  Where:
   H:  Hidden Module
```

Modules are usually loaded as part of a Slurm script, and that environment doesn't persist beyond the job, so `module avail` and `module load` are the main commands you'll be using day to day. However, if you're working on a node interactively, you may need to unload modules manually. The command `module unload modulename` unloads modules one at a time — for example, after loading the modules above:

```bash
module unload openssh
```

```
Lmod Warning: 
--------------------------------------------------------------------------------------------------------
The following dependent module(s) are not currently loaded: openssh/9.9p1-d4o73h6 (required by:
openmpi/4.1.7-762w)
--------------------------------------------------------------------------------------------------------
```

This warning is expected and can be safely ignored — Lmod is just noting that OpenMPI normally depends on OpenSSH, but it doesn't stop the module from being unloaded. Running `module list` again confirms OpenSSH is gone while the rest remain loaded:

```bash
module list
```

```
Currently Loaded Modules:
  1) binutils/2.43.1-ifi2qjn (H)   2) gcc/14.2.0-j33x   3) openmpi/4.1.7-762w
  Where:
   H:  Hidden Module
```

To unload all modules at once, use the command:

```bash
module purge
```

### Checking job resource utilization with `jobeff` and `seff`

Requesting the right amount of CPU and memory for a job is closely tied to module and software setup, since over- or under-requesting resources wastes either your queue time or shared cluster capacity. Easley provides two commands to help you spot mismatches between what you requested and what your job actually used.

For a currently running job, use `jobeff` to compare real-time CPU and memory utilization against your Slurm allocation. Run it with no arguments to see all of your currently running jobs:

```bash
jobeff
```

```
[##############################] 100% (1/1) Done

 [###############               ]  50% (1/2) Round 1/1: your_username (6 pids on 1 node)

[##############################] 100% (2/2) Done
Samples: 1 completed as a single sample using a 5s window.
NODE          USER          PARTITIONS          JOBS  ALLOC_CPU   BUSY_CPU   CPU_EFF%  ALLOC_GPU  GPU_PROCS      VRAM%   ALLOC_MEM          MEM_USED   MEM_EFF%     PROCS         LOCAL_IO            NET_IO
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

The same output, broken out for readability:

| Field | Value |
|---|---|
| State | COMPLETED (exit code 0) |
| Nodes | 1 |
| Cores per node | 16 |
| CPU Utilized | 00:01:10 |
| **CPU Efficiency** | **8.41%** of 00:13:52 core-walltime |
| Job Wall-clock time | 00:00:52 |
| Memory Utilized | 4.34 GB |
| **Memory Efficiency** | **13.57%** of 32.00 GB |

Here too, the job finished using only 8.41% of its requested CPU time and 13.57% of its requested memory — both strong indicators that the next submission of this job could request fewer cores and less memory, freeing up those resources for other jobs (including your own) and likely reducing queue wait times.

Both commands are useful for catching allocation vs. usage mismatches — for example, requesting 16 CPUs but only using 2, or requesting far more memory than the job ever touches. Adjusting future job submissions based on this feedback helps your jobs queue faster and leaves more resources available for other users.

*This quickbyte was validated on 6/22/2026*
