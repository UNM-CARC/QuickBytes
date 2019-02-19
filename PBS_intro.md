## Checking Job Status

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



