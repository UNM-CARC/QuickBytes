Conversion of PBS script to Slurm script
===================================

 
 Most of the machines in the UNM CARC uses PBS/TORQUE for scheduling jobs in HPC. However, Taos machine uses the Simple Linux Utility for Resource Management or SLURM for scheduling jobs. Slurm is little different from PBS in terms of syntax, commands used for resource allocation, job submission and monitoring and setting the environment variables. Detailed documentation of Slurm can be found in this [link](https://slurm.schedmd.com/documentation.html). For submitting a job in Taos, you have to submit a Slurm script. If you already have a PBS script, it can be easily converted to a Slurm without worrying about the technical details of Slurm. More details of submitting a [PBS](http://carc.unm.edu/user-support-2/using-carc-systems1/running-jobs/submitting-jobs.html) and [Slurm](https://github.com/UNM-CARC/QuickBytes/blob/master/Intro_to_slurm.md) can be found in their quickbytes links.
 
## Conversion of PBS to Slurm

For this purpose, we can use the cheet sheet tables below. The first table lists the most commonly used commands in PBS for submitting and monitoring jobs.

|  PBS Command        |  Slurm Command   | Command definition                  |
|  ------------       |  -------------   | ------------------                  |
| qsub \<job_script.pbs> |  sbatch \<job_script.slurm>  | Submit \<job-script>  to the queue|
| qsub -I \<options>  |  salloc \<options> |  Requesting interactive job|
|qstat -u \<user>    |   squeue -u \<user> | Status of jobs submitted by \<user> |
| qstat -f \<job-id> | scontrol show job \<job-id\> | Display details of \<job-id> |
| qdel \<job-id>     | scancel \<job-id> | Delete the listed \<job-id>|
|pbsnodes \<options> | sinfo | Display all nodes with thier information|

Now let's take a look at the commands used for resource allocation which goes into the PBS/SLURM script. In both cases, the script has to be initialized by the shell interpreter. Bash shell can be initialized in both PBS and SLURM by `#!/bin/bash/`
The resource allocation in PBS is precceded by `#PBS`
 and `#SBATCH` in SLURM. Let's look at various commands used for allocating resources.
 
|  PBS Command        |  Slurm Command   | Command definition                  |
|  ------------       |  -------------   | ------------------                  |
|-N <name> | --job-name= \<name>| Name of the job about to submit|
|-l procs= \<N> |--ntasks= \<N> | N processes to run|
|-l nodes=a:ppn=b | --ntasks= \<product of a and b> | a*b processes to run |
|-l walltime=\<HH:MM:SS>|--time=\<HH:MM:SS> | Maximum time required to finish the job|
|-l mem=\<Memory> | --mem = \<Memory> | Memory required per node|
|-l M \<email> | --mail-user=\<email>| Email ID for sending the job alerts to the user |
|-l m \<a,b,e\> |  --mail-type=\<BEGIN,END,FAIL,REQUEUE,ALL> | Sending email alerts at different situations|
|-o \<out_file>|--output=\<out_file>| Name of the output file|
|-e \<error_file> | --error=\<error_file>| Name of the file to write out the error/warning during execution|
|-j oe| Default in Slurm | Merge output and error files|

Let's look at different ways to set environment variable within the PBS/Slurm job.

|  PBS Command        |  Slurm Command   | Command definition                  |
|  ------------       |  -------------   | ------------------                  |
|$PBS\_O_HOST | $SLURM\_SUBMIT_HOST | Hostname from which job was submitted|
|$PBS\_JOBID | $SLURM\_JOB_ID | ID of the job sumitted|
|$PBS\_O_WORKDIR | $SLURM\_SUBMIT_DIR| Name of the directory from which job was submited|
|$PBS\_NODEFILE | $SLURM\_JOB_NODELIST| File containing allocated nodes/hostnames|

Now using the commands in the above tables,  we can easily convert a PBS script to a Slurm script. First let us look at a sample PBS script to run a python script test.py.

```bash
#!/bin/bash

#PBS -l nodes=1:ppn=1
#PBS -l walltime=01:00:00
#PBS -N test
#PBS -o test_out
#PBS -e test_error
#PBS -m bae
#PBS -M user@unm.edu

cd $PBS_O_WORKDIR/
python test.py

```
The corresponding Slurm script for the above PBS script can be written as

```bash
#!/bin/bash

#SBATCH --ntasks= 1
#SBATCH --time=01:00:00
#SBATCH --job-name test
#SBATCH --output = test_out
#SBATCH --error = test_error
#SBATCH --mail-type= BEGIN|FAIL|END
#SBATCH --mail-user =user@unm.edu

cd $SLURM_SUBMIT_DIR/
python test.py

```



