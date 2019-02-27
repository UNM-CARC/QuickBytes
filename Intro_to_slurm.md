# Slurm Workload Manager

Slurm is a resource manager and job scheduler designed for scheduling and allocating resources as per user job requirements.  Slurm is an open source software originally created by the Livermore Computing Center. 

## Slurm Commands
`sinfo` provides  information regarding resources that are available from server. 
Example :

    user@taos:~$ sinfo
    PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
    normal*      up 2-00:00:00      2   mix   taos[01,09]
    normal*      up 2-00:00:00      1   alloc taos02
    normal*      up 2-00:00:00      6   idle  taos[03-08]

From the output above we can see that one node (taos02) is allocated under a normal partition. Similarly, we can see that two nodes (taos01 and taos09) are in a mixed state meaning multiple users have resources allocated on the same node. The final line in the output shows that all other nodes (taos03-08) are currently idle.

`sinfo –N –l` provides more detailed information about individuals nodes including CPU count, memory, temporary disk space and so on. 

```
    user@taos:~$ sinfo -N -l
    Tue Feb 19 19:08:16 2019
    NODELIST   NODES PARTITION       STATE CPUS    S:C:T MEMORY TMP_DISK WEIGHT AVAIL_FE REASON
    taos01         1   normal*       mixed   80   2:20:2 386868   690861     10   (null) none
    taos02         1   normal*   allocated   40   2:10:2  64181   309479      1   (null) none
    taos03         1   normal*        idle   40   2:10:2  64181   309479      1   (null) none
    taos04         1   normal*        idle   40   2:10:2  64181   358607      1   (null) none
    taos05         1   normal*        idle   40   2:10:2  64181   309479      1   (null) none
    taos06         1   normal*        idle   40   2:10:2  64181   309479      1   (null) none
    taos07         1   normal*        idle   40   2:10:2  64181   309479      1   (null) none
    taos08         1   normal*        idle   40   2:10:2  64181   309479      1   (null) none
    taos09         1   normal*       mixed   40   2:10:2 103198  6864803     20   (null) none
```

More information regarding `sinfo` can be found by typing `man sinfo` at the command prompt while logged in to Taos.

`squeue` provides information regarding currently running jobs and the resources allocated to those jobs. 

```
    user@taos:~$ squeue
    JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
    22632    normal BinPacke username PD       0:00      1 (Resources)
    22548    normal    minia username  R 1-07:30:18      1 taos09
    22562    normal unicycle username  R   22:34:59      1 taos02
    22567    normal   sspace username  R   22:00:50      1 taos01
    22576    normal  megahit username  R    7:22:53      1 taos09
```

The output from `squeue`shows you the JobID, the type of partition, the name of the job, which user owns the job, the total elapsed time of the job, how many nodes are allocated to that job, and which nodes those are. 


To cancel a job, you can use `scancel <JOBID>` where `<JOBID>` refers to the JobID assigned to your job by Slurm.

## Slurm Job Submission

To submit a job in slurm you do so by submitting a shell script that outlines the resources you are requesting from the scheduler, the software needed for your job, and the commands you wish to run. The beginning of your submission scrip usually contains the #Hashbang specifying which interpreter should be used for the rest of the script, in this case we are using a `bash` shell as indicated by the code `#!/bin/bash`. The next portion of your submission script tells Slurm what resources you are requesting and is always preceeded by `#SBATCH` followed by flags for various parameters detailed below.


Example of a Slurm submission script : `slurm_submission.sh`

```
    #!/bin/bash
    #
    #SBATCH --job-name=demo
    #SBATCH --output=result.txt
    #
    #SBATCH --ntasks=4
    #SBATCH --time=00:10:00
    #SBATCH --mem-per-cpu=100

    srun hostname
    srun sleep
```

The above script is requesting from the scheduler an allocation of 4 nodes for 10 minutes with 100MB of ram per CPU. Note that we are requesting resources for four tasks, `--ntasks=4`, but not four nodes specifically. The default behavior of the scheduler is to provide one node per task, but this can be changed with the `--cpus-per-task` flag. Once the scheduler allocates the requested resources the job starts to run and the commands not preceeded by `#SBATCH` are interpreted and executed. The script first executes the `srun hostname` followed by `srun sleep` command. 

The arguments `–-job-name` and `–-output` correspond to name of the job you are submitting and the name of the output file where the any output not defined by the program being executed is saved. For example, anything printed to `stdout` will be saved in your `--output` file. 

To submit the job you execute the `sbatch` command followed by the name of your submission script, for example:

`sbatch submission.sh`

Once you execute the above command the job is queued until the requested resources are available for to be allocated to your job. 

Once your job is submitted you can use `sstat` command to see information about memory usage, CPU usage, and other metrics related to the jobs you own. 


Below is an example of a Slurm submission script that runs a small python program that takes an integer as an argument, creates a random number matrix with the dimensions defined by the integer you provided, then inverts that matrix and writes it to a CSV file. 

Below is our small python program named `demo.py` that we will be invoking. 

    # Import Libraries
    import numpy
    from numpy import linspace
    from numpy.random import rand
    from numpy.linalg import inv
    import argparse


    # define command line inputs
    parser = argparse.ArgumentParser()
    parser.add_argument("matrix", type=int, help='provide single integer for matrix')
    args = parser.parse_args()
    #define our matrix inverse function

    def matinv(x):
            mat = rand(x, x)
            b = inv(mat)
            return b
    out = matinv(args.matrix)
    numpy.savetxt("%d.csv" % args.matrix, out, delimiter=",")


Below is the Slurm submission script to submit our python program named `submission_python.sh`. This job can be submitted by typing `sbatch submission_python.sh` at the command prompt. Note the `module load` command that loads the software environment that contains the `numpy` package necessary to run our program.  

    #!/bin/bash
    #
    #SBATCH --job-name=demo
    #SBATCH --output=result.txt
    #
    #SBATCH --ntasks=4
    #SBATCH --time=10:00
    #SBATCH --mem-per-cpu=100

    module load anaconda3
    python demo.py 34

This brief tutorial should provide the basics necessary for submitting jobs to the Slurm Workload Manager on CARC machines. 



