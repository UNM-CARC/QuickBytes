# Example Slurm Scripts

To submit a job script to SLURM, use the `sbatch` command followed by the name of your script:

```bash
sbatch my_script.sh
```

This page walks through several example scripts of increasing complexity, then covers how to submit and run them.

---

## Creating a Script File

Before you can submit a job, you need to create a script file. You can use any text editor available on Easley. The three most common are:

**nano** — simplest, recommended for beginners:
```bash
nano my_script.sh
```
When finished editing, save with `Ctrl+O` then `Enter`, and exit with `Ctrl+X`.

**vi/vim** — available on every Unix system:
```bash
vi my_script.sh
```
Press `i` to enter insert mode and start typing. When finished, press `Esc`, then type `:wq` and hit `Enter` to save and quit. Type `:q!` to quit without saving.

**emacs** — feature-rich editor:
```bash
emacs my_script.sh
```
When finished editing, save with `Ctrl+X Ctrl+S` and exit with `Ctrl+X Ctrl+C`.

---

## Hello World

This example uses the Bash shell to print a simple "Hello World" message. The shell is specified by the shebang line at the top of the script (`#!/bin/bash`). If you do not specify a shell, your default shell will be used. Since this script uses only built-in Bash commands, no software modules are loaded — module usage is introduced in the next example.

Create a file called `hello.sh` and add the following:

```bash
#!/bin/bash
## Introduction for writing a Slurm script
## Requesting 1 node, 8 processors per node, and 2 hours of walltime.

#SBATCH --job-name=my_job
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --time=02:00:00
#SBATCH --partition=general
#SBATCH --mail-user=myemailaddress@unm.edu
#SBATCH --mail-type=BEGIN,END,FAIL

## Change to the directory the Slurm script was submitted from
cd $SLURM_SUBMIT_DIR

## Print a hello message indicating the host this is running on
export THIS_HOST=$(hostname)
echo "Hello World from host $THIS_HOST"
```

The number of tasks per node (`--ntasks-per-node`) must always be less than or equal to the number of physical CPU cores available on the node. On Easley, `--ntasks-per-node` should be <=64. We recommend always requesting the maximum number of processors per node to avoid multiple jobs on one node having to share memory. For more information see CARC systems information.

---

## Multi-Processor Example

This example runs a command across multiple CPUs on a single node using MPI.

Create a file called `multiprocessor.sh` and add the following:

```bash
#!/bin/bash
## Multi-processor example
## The Center for Advanced Research Computing
## at The University of New Mexico

#SBATCH --job-name=my_job
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --time=02:00:00
#SBATCH --partition=general
#SBATCH --mail-user=myemailaddress@unm.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load the OpenMPI module
module load openmpi

# Change to the directory where the Slurm script was submitted from
cd $SLURM_SUBMIT_DIR

# Run "hostname" on every CPU
# $SLURM_NTASKS is the total number of CPUs requested: 1 node x 8 CPUs = 8
mpirun -np $SLURM_NTASKS hostname
```

---

## Multi-Node Example

This example spreads work across multiple nodes using MPI. When running across multiple nodes, use `srun` instead of `mpirun` — SLURM passes node information to `srun` automatically.

Create a file called `multinode.sh` and add the following:

```bash
#!/bin/bash
## Multi-node example
## The Center for Advanced Research Computing
## at The University of New Mexico

#SBATCH --job-name=my_job
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --time=02:00:00
#SBATCH --partition=general
#SBATCH --mail-user=myemailaddress@unm.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Change to the directory the Slurm script was submitted from
cd $SLURM_SUBMIT_DIR

# Load the OpenMPI module
module load openmpi

# Run "hostname" on every CPU across all nodes
# $SLURM_NTASKS is the total number of CPUs requested: 4 nodes x 8 CPUs = 32
srun hostname
```

---

## Submitting Jobs

### Batch Submission

To submit a script to the batch scheduler, use `sbatch` followed by the script name. SLURM returns a job ID when the job is successfully submitted, which you can use to check the status of your job.

```bash
sbatch hello.sh
```

```
Submitted batch job 156452
```

Check the status of your job with:

```bash
squeue --me
```

Once the job completes, the output will be written to a file named `slurm-<jobid>.out` in the directory you submitted from. View it with:

```bash
cat slurm-156452.out
```

```
Hello World from host easley004
```

For more information on available options type `man sbatch`.

### Interactive Jobs

At times — such as when debugging — it can be useful to run a job interactively. Use `salloc` followed by your resource request, and SLURM will allocate a node and log you into it directly.

```bash
salloc --nodes=1 --ntasks=8 --time=00:05:00
```

```
salloc: Granted job allocation 156469
salloc: Nodes easley004 are ready for job
```

Once on the node, load your modules and run your script normally:

```bash
module load openmpi
bash helloworld_parallel.sh
```

```
Hello World from host easley004
Hello World from host easley004
Hello World from host easley004
Hello World from host easley004
Hello World from host easley004
Hello World from host easley004
Hello World from host easley004
Hello World from host easley004
```

When you are finished, type `exit` to release the node back to the pool.

> **Note:** CARC recommends submitting jobs via `sbatch` wherever possible, as job submission will catch errors in resource requests before the job runs. Reserve interactive sessions for debugging and development.

*This quickbyte was validated on 7/30/2026*
