#Submitting jobs
There are two ways you can run your jobs, namely submitting a PBS script and running a job interactively. Either way, jobs are submitted to CARC by the command `qsub`. For more information on available options type `man qsub`
###Submitting the PBS Script to the Batch Scheduler
In order to run our simple PBS script, we will need to submit it to the batch scheduler using the command `qsub` followed by the name of the script we would like to run. For more information please see our page on writing a [PBS batch script](www.carc.unm.edu/needtoaddlinkhere).
In the following example, we submit our simple `hello.pbs` script to the batch scheduler using `qsub`. Note that it returns the job identifier when the job is successfully submitted. You can use this job identifier to query the status of your job from your shell.  
For example:

```bash
qsub hello.pbs
64152.wheeler-sn.alliance.unm.edu
```
###Interactive PBS Jobs
Normally a job is submitted for execution on a cluster or supercomputer using the command `qsub script.pbs`. CARC recommends that all jobs are submitted this way as job submission fails if there are errors in resources requested. However, at times, such as when debugging, it can be useful to run a job interactively. To run a job in this way type `qsub -I` followed by resources requested, and the batch manager will log you into a node where you can directly run your code.  
For example, here is the output from an interactive session running our simple `helloworld_paralell.pbs` script:

```bash
qsub -I -lnodes=1:ppn=8 -lwalltime=00:05:00
qsub: waiting for job 64143.wheeler-sn.alliance.unm.edu to start
qsub: job 64143.wheeler-sn.alliance.unm.edu ready

Wheeler Portable Batch System Prologue
Job Id: 64143.wheeler-sn.alliance.unm.edu
Username: user
Job 64143.wheeler-sn.alliance.unm.edu running on nodes:
wheeler274
prologue running on host: wheeler274

bash helloworld.pbs
Hello World from host wheeler274
Hello World from host wheeler274
Hello World from host wheeler274
Hello World from host wheeler274
Hello World from host wheeler274
Hello World from host wheeler274
Hello World from host wheeler274
Hello World from host wheeler274
```
Three commands were executed here. The first,

```bash
qsub -I -lnodes=1:ppn=4 -lwalltime=00:05:00
```
asked the batch manager to provide one node of wheeler with all 8 of that node’s cores for use. It is good practice to request all available processors on a node to avoid multiple users being assigned to the same node. The walltime was specified as 5 minutes, since this was a simple code that would execute quickly. The second command, 

```bash
module load module load openmpi-3.1.1-intel-18.0.2-hlc45mq
```
loaded the openMPI software module to parallelize our script across all 8 processors; this ensures that the necessary MPI libraries would be available during execution. The third command, 

```bash
bash helloworld_parallel.pbs
```
ran the commands found within our `helloworld_paralell.pbs` script.
