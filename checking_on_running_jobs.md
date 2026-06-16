# Checking on Running Jobs

### Checking on the Status of your Job:
If you would like to check the status of your job, you can use the `squeue` command to do so. Typing `squeue` without any options will output all currently running or queued jobs to your terminal window, but there are many options to help display relevant information. To find more of these options type `man squeue` when logged in to a CARC machine. To see which jobs are running and queued in the standard output type the following in a terminal window:

```bash
squeue
```

Which should output:
```bash
JOBID    NAME             USER            TIME       ST  PARTITION
127506   pebble30_80      user            288:43:22  R   default
127508   pebble30_90      user            279:41:40  R   default
127509   pebble30_70      user            323:06:01  R   default
128012   canu_easley.sh   user            0:00:00    PD  default
```

The output of `squeue` gives you the Job ID, the name of the Job, which user owns that Job, elapsed time, the status of the Job — either pending (PD), running (R), or on hold (S) — and lastly, which partition the Job is in. To look at a specific job without seeing everything running you can use the Job ID by typing `squeue --job JobID`, or by using the `-u` flag followed by the username, `squeue -u user`.

For example:
```bash
squeue --job 127506
```
Which gives:
```bash
JOBID    NAME          USER       TIME       ST  PARTITION
127506   pebble30_80   user       289:04:10  R   default
```

A useful option is the `-l` (long format) flag which shows more information about jobs than `squeue` alone. As well as the information above, the `-l` option also outputs requested nodes, processors, memory, wall time, and actual runtime.

```bash
squeue -l
```
```Bash
JOBID    USER   PARTITION  NAME            ST  TIME        NODES  CPUS  MIN_MEMORY  TIME_LIMIT
127506   user   default    pebble30_80     R   229:13:18   1      8     --          240:00:00
127508   user   default    pebble30_90     R   229:09:10   1      8     --          240:00:00
127509   user   default    pebble30_70     R   229:08:46   1      8     --          240:00:00
128012   user   default    canu_easley.sh  PD  --          1      8     64G         24:00:00
```

`scontrol show job <jobid>` displays a full format output of information. It displays information about job name, owner, CPU time, memory usage, walltime, job status, error and output file paths, executing host, nodes, core allocation, and other details.

Example: inputting
```bash
scontrol show job 67048
```
should output
```bash
JobId=67048 JobName=BipolarCox_138
   UserId=user GroupId=users
   Priority=0 SubmitTime=2019-02-18T16:19:19
   StartTime=2019-02-19T12:47:56
   RunTime=00:35:58 TimeLimit=03:00:00 TimeLeft=02:24:02
   NodeList=easley21
   NumNodes=1 NumCPUs=2 NumTasks=2
   TRES=cpu=2,mem=64G,node=1
   JobState=RUNNING Partition=singleGPU
   StdErr=/users/user/experiments/newsuicidality-injury/BipolarCox_138.e67048
   StdOut=/users/user/experiments/newsuicidality-injury/BipolarCox_138.o67048
   Command=runRScript.sh
   WorkDir=/users/user/experiments/newsuicidality-injury
```

`watch squeue -u <username>` allows an interactive view of job statistics for that user, which updates every 2 seconds.

```bash
watch squeue -u ceodspsp
```
```bash
Every 2.0s: squeue -u ceodspsp                          Tue Feb 19 13:45:50 2019

JOBID    USER      PARTITION  NAME        ST  TIME       NODES  CPUS
66908    ceodspsp  dualGPU    smoke_1_5   R   21:50:33   2      32
67438    ceodspsp  dualGPU    smoke_5_10  R   09:39:00   2      32
```

### Determining which Nodes your Job is using:
If you would like to check which nodes your job is using, you can use `squeue -l` or `scontrol show job <jobid>` to see the node list. When your job is finished, the system will kill your processes on each node, and the node will be released back into the available resource pool.

```bash
squeue -l --job 55811
```
```bash
JOBID   USER   PARTITION  NAME        ST  TIME       NODES  NODELIST
55811   user   default    B19F_re5e4  R   47:30:42   4      easley280,easley282,easley295,easley296
```

Here, the nodes that this job is running on are easley296, easley295, easley282, and easley280, with 8 processors per node.

### Viewing Output and Error Files:
Once your job has completed, you should see two files, one output file and one error file, in the directory from which you submitted the job: `slurm-JobID.out` and `slurm-JobID.err` by default. You can customize these filenames in your Sbatch script using the `--output` and `--error` flags.

For the example job above, the default output and error files would be named `slurm-55811.out` and `slurm-55811.err` respectively. If the job was submitted with custom output flags such as:

```bash
#SBATCH --output=B19F_re5e4.o%j
#SBATCH --error=B19F_re5e4.e%j
```

then the files would be named `B19F_re5e4.o55811` and `B19F_re5e4.e55811`, matching the PBS naming convention.

Any output from the job sent to "standard output" will be written to the output file, and any output sent to "standard error" will be written to the error file. The amount of information in the output and error files varies depending on the program being run and how the Sbatch script was set up.

*This quickbyte was validated on 6/9/2026*
