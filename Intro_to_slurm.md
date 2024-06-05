# Slurm Workload Manager

Slurm is a resource manager and job scheduler designed for scheduling and allocating resources as per user job requirements.  Slurm is an open source software originally created by the Livermore Computing Center. 

## Slurm Commands
`sinfo` provides  information regarding resources that are available from server. 
Example :

    [rdscher@hopper ~]$ sinfo
    PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
    general*     up 2-00:00:00      2  alloc hopper[002-003]
    general*     up 2-00:00:00      8   idle hopper[001,004-010]
    debug        up    4:00:00      2   idle hopper[011-012]
    condo        up 2-00:00:00      4  idle* hopper[064-067]
    condo        up 2-00:00:00      2  down* hopper[033,051]
    condo        up 2-00:00:00     23    mix hopper[017-025,028,032,036,038,045,055-063]
    condo        up 2-00:00:00     14  alloc hopper[013-016,029-030,035,042,047,049-050,052-054]
    condo        up 2-00:00:00     12   idle hopper[026-027,031,034,037,039-041,043-044,046,048]
    geodef       up 7-00:00:00      1  idle* hopper065
    geodef       up 7-00:00:00      1  alloc hopper047
    geodef       up 7-00:00:00      2   idle hopper[046,048]
    biocomp      up 7-00:00:00      1  alloc hopper052


From the output above we can see that one node (taos02) is allocated under a normal partition. Similarly, we can see that two nodes (taos01 and taos09) are in a mixed state meaning multiple users have resources allocated on the same node. The final line in the output shows that all other nodes (taos03-08) are currently idle.

From the output above, we can see that 2 nodes on the general partition are allocated, and 8 are idle. The corresponding node id's are also listed. In this case, hopper002 and hopper003 specifically are the ones which are allocated on the general partition.

`sinfo –N –l` provides more detailed information about each individual node, including CPU count, memory, temporary disk space and so on. 

    [rdscher@hopper ~]$ sinfo -N -l
    Wed Jun 05 05:58:34 2024
    NODELIST   NODES PARTITION       STATE CPUS    S:C:T MEMORY TMP_DISK WEIGHT AVAIL_FE REASON
    hopper001      1  general*        idle 32     2:16:1  95027        0      1   (null) none
    hopper002      1  general*   allocated 32     2:16:1  95027        0      1   (null) none
    hopper003      1  general*   allocated 32     2:16:1  95027        0      1   (null) none
    hopper004      1  general*        idle 32     2:16:1  95027        0      1   (null) none
    hopper005      1  general*        idle 32     2:16:1  95027        0      1   (null) none
    hopper006      1  general*        idle 32     2:16:1  95027        0      1   (null) none
    hopper007      1  general*        idle 32     2:16:1  95027        0      1   (null) none
    hopper008      1  general*        idle 32     2:16:1  95027        0      1   (null) none


More information regarding `sinfo` can be found by typing `man sinfo` at the command prompt while logged in to Hopper.

`squeue` provides information regarding currently running jobs and the resources allocated to those jobs. 

    [rdscher@hopper ~]$ squeue
    JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
    2554110     condo 200-7.00   lzhang  R    4:52:39      1 hopper050
    2462342     debug ethylben   eattah PD       0:00      8 (PartitionNodeLimit)
    2548555   general  Ag-freq    yinrr  R 1-20:31:48      2 hopper[002-003]


The output from `squeue`shows you the JobID, the type of partition, the name of the job, which user owns the job, the total elapsed time of the job, how many nodes are allocated to that job, and which nodes those are. 

There are additional flags you can add to the squeue command to help parse the squeue output for the information you need. 
- `squeue --me` will only show you your jobs in the queue. 
- `squeue -p general` will only show you jobs in the general partition
A list of all flags can be found with the `man squeue` command. 

To cancel a job, you can use `scancel <JOBID>` where `<JOBID>` refers to the JobID assigned to your job by Slurm. Similar to the squeue command, you can also use the `scancel --me` to cancel all jobs you have scheduled. 

## Slurm Job Submission

To submit a job in slurm you do so by submitting a shell script that outlines the resources you are requesting from the scheduler, the software needed for your job, and the commands you wish to run. The beginning of your submission scrip usually contains the #Hashbang specifying which interpreter should be used for the rest of the script, in this case we are using a `bash` shell as indicated by the code `#!/bin/bash`. The next portion of your submission script tells Slurm what resources you are requesting and is always preceeded by `#SBATCH` followed by flags for various parameters detailed below.


Example of a Slurm submission script : `slurm_submission.slurm`


    #!/bin/bash
    #
    #SBATCH --job-name=demo
    #SBATCH --output=result.txt
    #
    #SBATCH --ntasks=4
    #SBATCH --time=00:10:00
    #SBATCH --mem-per-cpu=100
    #SBATCH --partition=general

    srun hostname
    srun sleep

The above script will request 4 cpu cores with 100MB of memory per cpu core. It will also choose the general partition. When we request in this way, the scheduler will give us the first 4 cpu cores it can find, whether that ends up being 1 cpu core per node across 4 nodes, or all 4 cores on the same node. You can add additional constraints, such as `ntasks-per-node`. Keep in mind that the more constraints you add, the longer your queue times may be. It might be the case that 4 cores spread across nodes becomes free instantly, while asking for all of those cores to be on the same node could take significantly longer.

The arguments `–-job-name` and `–-output` correspond to name of the job you are submitting and the name of the output file where the any output not defined by the program being executed is saved. For example, anything printed to `stdout` will be saved in your `--output` file. 

Of note here is the `--partition=general` (or `-p general`) command. This command specifies which partition, or queue, to submit your job to. If you are a member of a specific partition you likely are aware of the name of your partition, however you can see which partition you have access to with the `sinfo` command. If you leave this blank you will be submitted to the default or community partition. 

To submit the job you execute the `sbatch` command followed by the name of your submission script, for example:

`sbatch submission.slurm`

Once you execute the above command the job is queued until the requested resources are available for to be allocated to your job. 

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


Below is the Slurm submission script to submit our python program named `submission_python.slurm`. This job can be submitted by typing `sbatch submission_python.slurm` at the command prompt. Note the `module load` command that loads the software environment that contains the `numpy` package necessary to run our program.

    #!/bin/bash
    #
    #SBATCH --job-name=demo
    #SBATCH --output=result.txt
    #
    #SBATCH --ntasks=4
    #SBATCH --time=10:00
    #SBATCH --mem-per-cpu=100
    #SBATCH --partition=debug

    module load miniconda3
    python demo.py 34

This brief tutorial should provide the basics necessary for submitting jobs to the Slurm Workload Manager on CARC machines. 



