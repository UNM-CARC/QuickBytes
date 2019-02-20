Slurm is a resource manager and job scheduler designed for scheduling and allocating resources as per user job requirements.  Slurm is a open source software originally created by the Livermore Computing Center. 

## Slurm Commands
`sinfo` provides  information regarding resources that are available from server. 
Example :

    (ceodspsp) taos:~$ sinfo
    PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
    normal*      up 2-00:00:00      2    mix taos[01,09]
    normal*      up 2-00:00:00      1  alloc taos02
    normal*      up 2-00:00:00      6   idle taos[03-08]

From the above above, we can see one node(taos02)  is allocated under normal partition. Similarly 2 nodes from ( 01-09) are in mixed state referring some nodes being used and some being idle.  

`sinfo –N –l provides more information of Node including CPU count, memory, temporary disk and so. 

    (ceodspsp) taos:~$ sinfo -N -l
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

More information regarding sinfo can be found as `man sinfo`

`squeue`  provides information regarding currently allocated resources. 

    (ceodspsp) taos:~$ squeue
                 JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 22632    normal BinPacke schultzj PD       0:00      1 (Resources)
                 22548    normal    minia   lijing  R 1-07:30:18      1 taos09
                 22562    normal unicycle  bishoyh  R   22:34:59      1 taos02
                 22567    normal   sspace   lijing  R   22:00:50      1 taos01
                 22576    normal  megahit   lijing  R    7:22:53      1 taos09

To cancel a job, you can use `scancel <JOBID>` . TIME stands for the current running time of the job. 

## Slurm JOB Submission

To create a job in slurm, you need to write a shell script called submission script which comprises of resource requests and job steps. The Resource requests consists details regarding number of CPUs, wall time, RAM and disk requirements. The submission script are usually prefixed with SBATCH which Slurm understands as parameters for resource request and submission.

Example of a Slurm submission script : `submission.sh`

    #!/bin/bash
    #
    #SBATCH --job-name=demo
    #SBATCH --output=result.txt
    #
    #SBATCH --ntasks=4
    #SBATCH --time=10:00
    #SBATCH --mem-per-cpu=100

    srun hostname
    srun sleep

Above script requests for allocation of 4 CPUs for 10 minutes with 100MB of ram per CPU. AS the job starts to run, the script first execute the `srun hostname` followed by `srun sleep`. 

Arguments `–-job-name` and `–-output`  correspond to name of the job and output file name where the results are saved. 

To submit the job you need to run 

`sbatch submission.sh`

Once you execute the above command, the job enters into pending state until the resources are available for execution. If the job completes successfully then it goes to COMPLETED state, otherwise goes to FAILED state. 

Once the job is submitted, you can use `sstat` command to see information about memory usage, CPU usage,etc. 

As the job gets successfully completed, you can see the results by executing `cat result.txt`

Example of a Slurm submission script for python program : `submission_python.sh`

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


`demo.py` script

    # Import Libraries
    import numpy
    from numpy import linspace
    from numpy.random import rand
    from numpy.linalg import inv
    import timeit
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



