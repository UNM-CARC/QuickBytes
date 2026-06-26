# Checking on running jobs
### Checking on the status of your Job:
If you would like to check the status of your job, you can use the `squeue` command to do so. Typing `squeue` without any options will output all currently running or queued jobs to your terminal window, but there are many options to help display relevant information. To find more of these options type `man squeue` when logged in to a CARC machine. To see which jobs are running and queued in the standard output, type 'squeue' in a terminal window:

```bash
squeue
 JOBID  PARTITION     NAME     USER   ST  TIME  NODES NODELIST(REASON)
 155161  bigmem       job1     usr1 PD  0:00      1  (Resources)
 155071  bigmem       job2     usr2  R  17:17:00  1  easley050
 155068  bigmem       job3     usr3  R  17:29:37  1  easley050
 152827  debug        job4     usr4 PD  0:00      1  (PartitionTimeLimit)
```

The output of `squeue` shows the job ID, partition, job name, job owner, job status (such as pending (PD) or running (R)), the number of nodes allocated, and the reason a job is pending or the names of the nodes on which a job is running. To view a specific job in the queue without listing every running job, you can use the job ID with `squeue -j <jobID>`, or you can filter by user with `squeue -u <username>`. Additionally, you can use `squeue --me` to veiw only your jobs. 
For example:

```bash
 squeue -j 155161
JOBID PARTITION   NAME   USER   ST   TIME  NODES NODELIST(REASON)
155161  bigmem    job1   user1  PD   0:00    1    (Resources)
```
 
A useful Slurm option is `squeue -l`, which displays more detailed job information than squeue alone; in addition to the standard fields, it includes requested resources such as nodes, tasks, memory, wall-time limits, and the job’s actual runtime.
The scontrol `show job <jobID>` command in SLURM provides a “full” display of information about a job. It shows details such as the job name, owner, CPU time, memory usage, walltime, job status, paths to output and error files, executing nodes, core allocation, and other relevant information. Using `scontrol show job <jobID>` displays these details for the specified job ID.

`watch squeue -u <username>` allows an interactive statistics of jobs for that user which updates for every 2sec. 

### Determining which nodes your Job is using:
If you would like to check which nodes your job is using, you can pass the `-j` option to squeue. When your job is finished, your processes on each node will be killed by the system, and the node will be released back into the available resource pool.

```bash
squeue -j  156510
 JOBID PARTITION     NAME     USER   ST     TIME  NODES NODELIST(REASON)
 156510   l40s     interact    usr   R       2:02     1   easley056
```
Here, the node that this job is running is easley056.
 
### Viewing Output and Error Files:
Once your job has completed, you should see two files, one output file and one error file, in the directory from which you submitted the Job: slurm-JobID.out and slurm-JobID.err (where JobID refers to the ID of the Job returned by `sbatch`).  
For the example job above, these two files would be named `slurm-155161.out` and `slurm-155161.err` respectively.  
Any output from the job sent to “standard output” will be written to the output file, and any output sent to “standard error” will be written to the error file. The amount of information in the output and error files varies depending on the program being run and how the sbatch batch script was set up. 




