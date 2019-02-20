#Checking on running jobs
###Checking on the status of your Job:
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
`qstat -f` Specifies a "full" format display of information.  It displays the informations regarding job name,owner,cpu_time, memory usage, walltime, job staus, error and output file path, executing host, nodes and core allocation and others.  
`qstat -f  <jobid>` displays the information corresponding to that jobid. 
Example 

    (user) xena:~$ qstat qstat -f 67048
    Job Id: 67048.xena.xena.alliance.unm.edu
        Job_Name = BipolarCox_138
        Job_Owner = user@xena.xena.alliance.unm.edu
        resources_used.cput = 00:35:53
        resources_used.energy_used = 0
        resources_used.mem = 31427708kb
        resources_used.vmem = 31792364kb
        resources_used.walltime = 00:35:58
        job_state = R
        queue = singleGPU
        server = xena.xena.alliance.unm.edu
        Checkpoint = u
        ctime = Mon Feb 18 16:19:19 2019
        Error_Path = xena.xena.alliance.unm.edu:/users/user/experiments/newsui
            cidality-injury/BipolarCox_138.e67048
        exec_host = xena21/0-1
        Hold_Types = n
        Join_Path = n
        Keep_Files = n
        Mail_Points = a
        mtime = Tue Feb 19 12:47:56 2019
        Output_Path = xena.xena.alliance.unm.edu:/users/user/experiments/newsu
            icidality-injury/BipolarCox_138.o67048
        Priority = 0
        qtime = Mon Feb 18 16:19:19 2019
        Rerunable = True
        Resource_List.nodect = 1
        Resource_List.nodes = 1:ppn=2
        Resource_List.walltime = 03:00:00
        session_id = 74594
        Shell_Path_List = /bin/bash
        euser = dccannon
        egroup = users
        queue_type = E
        etime = Mon Feb 18 16:19:19 2019
        submit_args = -N BipolarCox_138 -v run_id=138 runRScript.sh
        start_time = Tue Feb 19 12:47:56 2019
        Walltime.Remaining = 8598
        start_count = 1
        fault_tolerant = False
        job_radix = 0
        submit_host = xena.xena.alliance.unm.edu
        request_version = 1

`watch qstat -u <username>` allows an interactive statistics of jobs for that user which updates for every 2sec.  Example

    (user) xena:~$watch qstat -u ceodspsp
    Every 2.0s: qstat -u ceodspsp                                                           Tue Feb 19 13:45:50 2019


    xena.xena.alliance.unm.edu:
                                                                                      Req'd       Req'd       Elap
    Job ID                  Username    Queue    Jobname          SessID  NDS   TSK   Memory      Time    S   Time
    ----------------------- ----------- -------- ---------------- ------ ----- ------ --------- --------- - ---------
    66908.xena.xena.allian  ceodspsp    dualGPU  smoke_1_5        103419     2     32       --   48:00:00 R  21:50:33
    67438.xena.xena.allian  ceodspsp    dualGPU  smoke_5_10        66632     2     32       --   48:00:00 R  09:39:00

###Determining which nodes your Job is using:
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
 
###Viewing Output and Error Files:
Once your job has completed, you should see two files, one output file and one error file, in the directory from which you submitted the Job: Jobname.oJobID and Jobname.eJobID (where Jobname refers to the name of the Job returned by `qstat`, and JobID refers to the numerical portion of the job identifier returned by `qstat`).  
For the example job above, these two files would be named `B19F_re5E4.o55811` and `B19F_re5E4.e55811` respectively.  
Any output from the job sent to “standard output” will be written to the output file, and any output sent to “standard error” will be written to the error file. The amount of information in the output and error files varies depending on the program being run and how the PBS batch script was set up. 




