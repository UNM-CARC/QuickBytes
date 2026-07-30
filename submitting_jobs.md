# Submitting jobs

There are two ways you can run your jobs, namely submitting a Slurm script and running a job interactively. Either way, jobs are submitted to CARC by the command `sbatch`. For more information on available options type `man sbatch`.

### Submitting the Slurm Script to the Batch Scheduler

In order to run our simple Slurm script, we will need to submit it to the batch scheduler using the command `sbatch` followed by the name of the script we would like to run. For more information please see our page on [writing a Slurm batch script](https://github.com/UNM-CARC/QuickBytes/blob/master/submitting_sbatch_jobs.md).

In the following example, we submit our simple `hello.sbatch` script to the batch scheduler using `sbatch`. Note that it returns the job identifier when the job is successfully submitted. You can use this job identifier to query the status of your job from your shell.
For example:

```bash
sbatch hello.sbatch
```

```
Submitted batch job 1035461
```

### Interactive Slurm Jobs

Normally a job is submitted for execution on a cluster or supercomputer using the command `sbatch script.sbatch`. CARC recommends that all jobs are submitted this way as job submission fails if there are errors in resources requested. However, at times, such as when debugging, it can be useful to run a job interactively. To run a job in this way type `salloc` followed by resources requested, and the batch manager will log you into a node where you can directly run your code.

Here's our simple `helloworld_parallel.sbatch` script, which prints a hello message from every task it's given:

```bash
export THIS_HOST=$(hostname)
echo "Job $SLURM_JOB_ID running on $THIS_HOST"
echo "Hello World from host $THIS_HOST"
```

To actually run it across multiple tasks, it needs to be launched with `mpirun`. Just running it with plain `bash` would only ever execute it once, regardless of how many tasks you requested with `salloc`.

Here's an interactive session running it across all 8 tasks of a node:

```bash
salloc --nodes=1 --ntasks=8 --time=00:05:00
```

```
salloc: Granted job allocation 1035500
salloc: Nodes easley031 are ready for job
```

```bash
module load openmpi
mpirun -np 8 bash $PWD/helloworld_parallel.sbatch
```

```
Job 1035500 running on easley031
Hello World from host easley031
Job 1035500 running on easley031
Hello World from host easley031
Job 1035500 running on easley031
Hello World from host easley031
Job 1035500 running on easley031
Hello World from host easley031
Job 1035500 running on easley031
Hello World from host easley031
Job 1035500 running on easley031
Hello World from host easley031
Job 1035500 running on easley031
Hello World from host easley031
Job 1035500 running on easley031
Hello World from host easley031
```

Three commands were executed here. The first,

```bash
salloc --nodes=1 --ntasks=8 --time=00:05:00
```

asked the batch manager to provide one node of easley with all 8 of that node's cores for use. It is good practice to request all available processors on a node to avoid multiple users being assigned to the same node. The walltime was specified as 5 minutes, since this was a simple code that would execute quickly. The second command,

```bash
module load openmpi
```

loaded the openMPI software module, giving us the MPI libraries and the `mpirun` launcher needed to actually run the script across all 8 tasks. The third command,

```bash
mpirun -np 8 bash $PWD/helloworld_parallel.sbatch
```

ran the `helloworld_parallel.sbatch` script across all 8 requested tasks, using an absolute path since `mpirun` doesn't necessarily preserve your current directory across every task.

*This quickbyte was validated on 7/30/2026*
