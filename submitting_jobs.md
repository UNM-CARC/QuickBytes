# Submitting Jobs
There are two ways you can run your jobs, namely submitting an Sbatch script and running a job interactively. Either way, jobs are submitted to CARC using the command `sbatch`. For more information on available options type `man sbatch`.

### Submitting the Sbatch Script to the Batch Scheduler
In order to run our simple Sbatch script, we will need to submit it to the batch scheduler using the command `sbatch` followed by the name of the script we would like to run. For more information please see our page on writing an [Sbatch script](https://www.carc.unm.edu/needtoaddlinkhere).

In the following example, we submit our simple `hello.sh` script to the batch scheduler using `sbatch`. Note that it returns the job identifier when the job is successfully submitted. You can use this job identifier to query the status of your job from your shell.

For example:
```bash
sbatch hello.sh
Submitted batch job 64152
```

### Interactive SLURM Jobs
Normally a job is submitted for execution on a cluster or supercomputer using the command `sbatch script.sh`. CARC recommends that all jobs are submitted this way as job submission fails if there are errors in resources requested. However, at times, such as when debugging, it can be useful to run a job interactively. To run a job in this way use `srun` followed by the resources requested, and the batch manager will log you into a node where you can directly run your code.

For example, here is the output from an interactive session running our simple `helloworld_parallel.sh` script:
```bash
srun --nodes=1 --ntasks-per-node=8 --time=00:05:00 --pty bash
srun: job 64143 queued and waiting for resources
srun: job 64143 has been allocated resources
Easley SLURM Prologue
Job Id: 64143
Username: user
Job 64143 running on nodes:
easley274
prologue running on host: easley274
bash helloworld_parallel.sh
Hello World from host easley274
Hello World from host easley274
Hello World from host easley274
Hello World from host easley274
Hello World from host easley274
Hello World from host easley274
Hello World from host easley274
Hello World from host easley274
```

Three commands were executed here. The first,
```bash
srun --nodes=1 --ntasks-per-node=8 --time=00:05:00 --pty bash
```
asked the batch manager to provide one node of Easley with all 8 of that node's cores for use. It is good practice to request all available processors on a node to avoid multiple users being assigned to the same node. The walltime was specified as 5 minutes, since this was a simple code that would execute quickly. The second command,
```bash
module load openmpi-3.1.1-intel-18.0.2-hlc45mq
```
loaded the openMPI software module to parallelize our script across all 8 processors; this ensures that the necessary MPI libraries would be available during execution. The third command,
```bash
bash helloworld_parallel.sh
```
ran the commands found within our `helloworld_parallel.sh` script.