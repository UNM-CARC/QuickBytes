# Checking on running jobs
### Checking on the status of your Job:
If you would like to check the status of your job, you can use the `qstat` command to do so. Typing `qstat` without any options will output all currently running or queued jobs to your terminal window, but there are many options to help display relevant information. To find more of these options type `man qstat` when logged in to a CARC machine. To see which jobs are running and queued in the standard output type the following in a terminal window:

```bash
qstat
Job ID                    Name             User            Time Use S Queue
------------------------- ---------------- --------------- -------- - -----
127506.wheeler-sn.alliance.un pebble30_80      user        288:43:2 R default
127508.wheeler-sn.alliance.un pebble30_90      user        279:41:4 R default
127509.wheeler-sn.alliance.un pebble30_70      user        323:06:0 R default
128012.wheeler-sn.alliance.un canu_wheeler.sh  user               0 Q default
```

The output of `qstat` give you the Job ID, the name of the Job, which user owns that Job, CPU time, the status of the Job, either queued (Q), running (R), and sometimes on hold (H), and lastly, which queue the Job is in. To look at a specific job without seeing everything running you can use the Job ID by typing `qstat Job ID`, or by using the `-u` flag followed by the username, `qstat -u user`.  
For example:

```bash
qstat 127506
Job ID                    Name             User            Time Use S Queue
------------------------- ---------------- --------------- -------- - -----
127506.wheeler-sn.alliance.un pebble30_80      user        289:04:1 R default
```
 
 A useful option is the `-a` flag which shows more information about jobs than `qstat` alone. As well as the information above, the `-a` option also outputs requested nodes, processors, memory, wall time, and actual runtime instead of CPU time. 
 
```bash
 Job ID                  Username    Queue    Jobname          SessID  NDS   TSK   Memory      Time    S   Time
----------------------- ----------- -------- ---------------- ------ ----- ------ --------- --------- - ---------
127506.wheeler-sn.alli  user        default  pebble30_80        8739     1      8       --  240:00:00 R 229:13:18
127508.wheeler-sn.alli  user        default  pebble30_90       25507     1      8       --  240:00:00 R 229:09:10
127509.wheeler-sn.alli  user        default  pebble30_70       20372     1      8       --  240:00:00 R 229:08:46
128012.wheeler-sn.alli  user        default  canu_wheeler.sh     --      1      8      64gb  24:00:00 Q

```



### Determining which nodes your Job is using:
If you would like to check which nodes your job is using, you can pass the `-n` option to qstat. When your job is finished, your processes on each node will be killed by the system, and the node will be released back into the available resource pool.

```bash
qstat -an
wheeler-sn.alliance.unm.edu:                                                                                                                            
Job ID                           Username  Queue      Jobname     SessID   NDS  TSK  Memory   Time        S  Time
---------------------------  ------------  --------   ----------  -------  ---  ---  ------  --------    --  --------
55811.wheeler-sn.alliance.u        user    default    B19F_re5e4        0    4   32     - -  48:00:00     R  47:30:42
      wheeler296/0-7+wheeler295/0-7+wheeler282/0-7+wheeler280/0-7
```
Here,  the nodes that this job is running on are wheeler296, wheeler295, wheeler282, and wheeler280, with 8 processors per node.
 
### Viewing Output and Error Files:
Once your job has completed, you should see two files, one output file and one error file, in the directory from which you submitted the Job: Jobname.oJobID and Jobname.eJobID (where Jobname refers to the name of the Job returned by `qstat`, and JobID refers to the numerical portion of the job identifier returned by `qstat`).  
For the example job above, these two files would be named `B19F_re5E4.o55811` and `B19F_re5E4.e55811` respectively.  
Any output from the job sent to “standard output” will be written to the output file, and any output sent to “standard error” will be written to the error file. The amount of information in the output and error files varies depending on the program being run and how the PBS batch script was set up. 

