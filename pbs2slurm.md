# Conversion of SLURM Script to PBS Script

Most machines at CARC use SLURM for scheduling jobs in HPC. However, if you need to run jobs on a system that uses PBS/TORQUE, your SLURM scripts can be easily converted without needing to learn all the technical details of PBS. More details on submitting a [SLURM job](https://github.com/UNM-CARC/QuickBytes/blob/master/Intro_to_slurm.md) can be found in the SLURM quickbyte. Detailed documentation of PBS/TORQUE can be found at this [link](https://adaptivecomputing.com/cherry-services/torque-resource-manager/).

## Conversion of SLURM to PBS

The tables below can be used as a reference when converting your scripts. The first table lists the most commonly used commands for submitting and monitoring jobs.

| SLURM Command | PBS Command | Command Definition |
| ------------- | ----------- | ------------------ |
| `sbatch <job_script.sh>` | `qsub <job_script.pbs>` | Submit a job script to the queue |
| `salloc <options>` | `qsub -I <options>` | Request an interactive job |
| `squeue -u <user>` | `qstat -u <user>` | Status of jobs submitted by a user |
| `scontrol show job <job-id>` | `qstat -f <job-id>` | Display details of a job |
| `scancel <job-id>` | `qdel <job-id>` | Cancel a job |
| `sinfo` | `pbsnodes <options>` | Display all nodes with their information |

Now let's look at the resource allocation flags that go inside the job script. In both cases the script is initialized with `#!/bin/bash`. In SLURM, resource allocation lines are preceded by `#SBATCH`; in PBS they are preceded by `#PBS`.

| SLURM Flag | PBS Flag | Definition |
| ---------- | -------- | ---------- |
| `--job-name=<name>` | `-N <name>` | Name of the job |
| `--ntasks=<N>` | `-l procs=<N>` | Number of processes to run |
| `--ntasks=<a*b>` | `-l nodes=a:ppn=b` | Processes spread across nodes |
| `--time=<HH:MM:SS>` | `-l walltime=<HH:MM:SS>` | Maximum time to finish the job |
| `--mem=<Memory>` | `-l mem=<Memory>` | Memory required per node |
| `--mail-user=<email>` | `-M <email>` | Email address for job alerts |
| `--mail-type=<BEGIN,END,FAIL>` | `-m <b,e,a>` | When to send email alerts |
| `--output=<out_file>` | `-o <out_file>` | Name of the output file |
| `--error=<error_file>` | `-e <error_file>` | Name of the error file |

The following table shows the equivalent environment variables available inside your running job.

| SLURM Variable | PBS Variable | Definition |
| -------------- | ------------ | ---------- |
| `$SLURM_SUBMIT_HOST` | `$PBS_O_HOST` | Hostname from which the job was submitted |
| `$SLURM_JOB_ID` | `$PBS_JOBID` | ID of the submitted job |
| `$SLURM_SUBMIT_DIR` | `$PBS_O_WORKDIR` | Directory from which the job was submitted |
| `$SLURM_JOB_NODELIST` | `cat $PBS_NODEFILE` | Allocated nodes/hostnames |

## Example Conversion

Here is a sample SLURM script to run a Python script `test.py`:

```bash
#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=01:00:00
#SBATCH --job-name=test
#SBATCH --output=test.out
#SBATCH --error=test.err
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --mail-user=user@unm.edu

cd $SLURM_SUBMIT_DIR/
python test.py
```

The equivalent PBS script for the above is:

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

*This quickbyte was validated on 6/9/2026*