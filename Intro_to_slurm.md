# SLURM Workload Manager

SLURM is a resource manager and job scheduler designed for scheduling and allocating resources as per user job requirements. SLURM is open source software originally created by the Livermore Computing Center.

## SLURM Commands

`sinfo` provides information regarding resources that are available on the system.

Example:
```bash
user@easley:~$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up 2-00:00:00      2   mix   easley[01,09]
normal*      up 2-00:00:00      1   alloc easley02
normal*      up 2-00:00:00      6   idle  easley[03-08]
```

From the output above we can see that one node (easley02) is fully allocated under the normal partition. Similarly, we can see that two nodes (easley01 and easley09) are in a mixed state, meaning multiple users have resources allocated on the same node. The remaining nodes (easley03-08) are currently idle.

`sinfo -N -l` provides more detailed information about individual nodes including CPU count, memory, temporary disk space, and so on.

```bash
user@easley:~$ sinfo -N -l
NODELIST   NODES PARTITION     STATE CPUS    S:C:T MEMORY TMP_DISK WEIGHT REASON
easley01       1   normal*     mixed   80   2:20:2 386868   690861     10   none
easley02       1   normal*  allocated  40   2:10:2  64181   309479      1   none
easley03       1   normal*      idle   40   2:10:2  64181   309479      1   none
easley04       1   normal*      idle   40   2:10:2  64181   358607      1   none
easley05       1   normal*      idle   40   2:10:2  64181   309479      1   none
```

More information regarding `sinfo` can be found by typing `man sinfo` at the command prompt while logged in to a CARC machine.

`squeue` provides information regarding currently running jobs and the resources allocated to those jobs.

```bash
user@easley:~$ squeue
JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
22632    normal  my_job     user  PD       0:00      1 (Resources)
22548    normal  my_job2    user   R 1-07:30:18      1 easley09
22562    normal  my_job3    user   R   22:34:59      1 easley02
```

The output from `squeue` shows you the JobID, the partition, the name of the job, which user owns the job, the job state, the total elapsed time, how many nodes are allocated to that job, and which nodes those are.

To cancel a job, use `scancel <JOBID>` where `<JOBID>` refers to the JobID assigned to your job by SLURM.

For more information on any of these commands, type `man squeue`, `man sinfo`, or `man scancel` at the command prompt when logged in to a CARC machine.

## SLURM Job Submission

To submit a job in SLURM you do so by submitting a shell script that outlines the resources you are requesting from the scheduler, the software modules needed for your job, and the commands you wish to run. The beginning of your submission script contains the hashbang `#!/bin/bash`, which specifies that the script should be interpreted using the Bash shell. The next portion tells SLURM what resources you are requesting, and each of these lines is always preceded by `#SBATCH` followed by flags for the various parameters detailed below.

Example Sbatch submission script `slurm_submission.sh`:
```bash
#!/bin/bash
#
#SBATCH --job-name=demo
#SBATCH --output=result.txt
#
#SBATCH --ntasks=4
#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=100
#SBATCH --partition=partition_name

srun hostname
srun sleep
```

The above script requests an allocation of 4 tasks for 10 minutes with 100MB of RAM per CPU. Note that we are requesting resources for four tasks with `--ntasks=4`, but not four nodes specifically. The default behavior of the scheduler is to provide one node per task, but this can be changed with the `--cpus-per-task` flag. Once the scheduler allocates the requested resources the job starts to run and the commands not preceded by `#SBATCH` are interpreted and executed.

The `--job-name` flag sets the name of the job you are submitting. The `--output` flag sets the name of the output file where any output not defined by the program being executed is saved — for example, anything printed to `stdout` will be saved here.

The `--partition` flag (or `-p`) specifies which partition, or queue, to submit your job to. If you are a member of a specific partition you likely already know its name, however you can see which partitions you have access to with the `sinfo` command. If you omit this flag your job will be submitted to the default community partition.

To submit the job, execute the `sbatch` command followed by the name of your submission script:

```bash
sbatch submission.sh
```

Once executed, the job is queued until the requested resources are available. Once your job is running you can use the `sstat` command to see information about memory usage, CPU usage, and other metrics related to your jobs.

## Example: Running a Python Script

Below is an example Sbatch submission script that runs a small Python program. The program takes an integer as an argument, creates a random matrix with dimensions defined by that integer, inverts the matrix, and writes the result to a CSV file.

Our Python program `demo.py`:
```python
import numpy
from numpy.random import rand
from numpy.linalg import inv
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("matrix", type=int, help='provide single integer for matrix dimensions')
args = parser.parse_args()

def matinv(x):
    mat = rand(x, x)
    b = inv(mat)
    return b

out = matinv(args.matrix)
numpy.savetxt("%d.csv" % args.matrix, out, delimiter=",")
```

Our submission script `submission_python.sh`:
```bash
#!/bin/bash
#
#SBATCH --job-name=demo
#SBATCH --output=result.txt
#
#SBATCH --ntasks=4
#SBATCH --time=10:00
#SBATCH --mem-per-cpu=100
#SBATCH --partition=default

module load anaconda3
python demo.py 34
```

This job can be submitted by typing `sbatch submission_python.sh` at the command prompt. Note the `module load` command that loads the software environment containing the `numpy` package necessary to run the program. For more information on loading software modules refer to the help page 'Managing Software Modules'.

*This quickbyte was validated on 6/9/2026*