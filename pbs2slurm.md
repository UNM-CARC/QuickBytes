# Converting a PBS Script to a Slurm Script

Most CARC systems historically supported PBS/TORQUE for scheduling jobs in HPC environments. However, current CARC systems primarily use Slurm (Simple Linux Utility for Resource Management) for job scheduling.

> **Note:** PBS is **not supported on Easley**. Although PBS may still be available on Hopper, we recommend using **Slurm** for all new jobs and workflows to ensure compatibility across CARC systems and to align with current support and documentation.

Slurm differs from PBS in its syntax, commands for resource allocation, job submission and monitoring, and environment variables.

Detailed Slurm documentation is available here:
https://slurm.schedmd.com/documentation.html

To submit jobs on Slurm-based systems, you must submit a Slurm job script. If you already have a PBS script, converting it to Slurm is usually straightforward.

Additional references:

* PBS job submission: http://carc.unm.edu/user-support-2/using-carc-systems1/running-jobs/submitting-jobs.html
* Slurm QuickBytes: https://github.com/UNM-CARC/QuickBytes/blob/master/Intro_to_slurm.md

---

## Converting PBS Commands to Slurm Commands

The table below lists commonly used PBS commands and their Slurm equivalents.

| PBS Command             | Slurm Command                | Description                                     |
| ----------------------- | ---------------------------- | ----------------------------------------------- |
| `qsub <job_script.pbs>` | `sbatch <job_script.slurm>`  | Submit a batch job                              |
| `qsub -I <options>`     | `salloc <options>`           | Request an interactive job                      |
| `qstat -u <user>`       | `squeue -u <user>`           | Display jobs submitted by a user                |
| `qstat -f <job-id>`     | `scontrol show job <job-id>` | Show detailed information for a job             |
| `qdel <job-id>`         | `scancel <job-id>`           | Cancel a job                                    |
| `pbsnodes <options>`    | `sinfo`                      | Display available nodes and cluster information |

---

## Resource Allocation Directives

Both PBS and Slurm scripts begin with a shell interpreter declaration.

Use:

```bash
#!/bin/bash
```

Resource directives are prefixed with:

* `#PBS` for PBS
* `#SBATCH` for Slurm

Common resource allocation options are shown below.

| PBS Directive            | Slurm Directive                               | Description                               |
| ------------------------ | --------------------------------------------- | ----------------------------------------- |
| `-N <name>`              | `--job-name=<name>`                           | Job name                                  |
| `-l procs=<N>`           | `--ntasks=<N>`                                | Number of tasks/processes                 |
| `-l nodes=a:ppn=b`       | `--nodes=a` + `--ntasks-per-node=b`           | Request `a` nodes with `b` tasks per node |
| `-l walltime=<HH:MM:SS>` | `--time=<HH:MM:SS>`                           | Maximum wall-clock runtime                |
| `-l mem=<memory>`        | `--mem=<memory>`                              | Memory requested per node                 |
| `-M <email>`             | `--mail-user=<email>`                         | Email address for notifications           |
| `-m <a,b,e>`             | `--mail-type=BEGIN,END,FAIL,REQUEUE,ALL`      | Email notification conditions             |
| `-o <out_file>`          | `--output=<out_file>`                         | Standard output file                      |
| `-e <error_file>`        | `--error=<error_file>`                        | Standard error file                       |
| `-j oe`                  | Default behavior in many Slurm configurations | Combine stdout and stderr                 |

> **Recommendation:** Prefer `--nodes` and `--ntasks-per-node` instead of collapsing everything into `--ntasks`, since this maps more directly to how resources are allocated in Slurm.

---

## Environment Variables

PBS and Slurm expose similar environment variables during job execution.

| PBS Variable        | Slurm Variable        | Description                                |
| ------------------- | --------------------- | ------------------------------------------ |
| `$PBS_O_HOST`       | `$SLURM_SUBMIT_HOST`  | Host where the job was submitted           |
| `$PBS_JOBID`        | `$SLURM_JOB_ID`       | Job ID                                     |
| `$PBS_O_WORKDIR`    | `$SLURM_SUBMIT_DIR`   | Directory from which the job was submitted |
| `cat $PBS_NODEFILE` | `$SLURM_JOB_NODELIST` | Allocated nodes                            |

If you need individual node names in Slurm:

```bash
scontrol show hostnames $SLURM_JOB_NODELIST
```

---

## Example: PBS Script

Below is a sample PBS script that runs `test.py`.

```bash
#!/bin/bash

#PBS -l nodes=1:ppn=1
#PBS -l walltime=01:00:00
#PBS -N test
#PBS -o test.out
#PBS -e test.err
#PBS -m bae
#PBS -M user@unm.edu

cd "$PBS_O_WORKDIR"

python test.py
```

---

## Equivalent Slurm Script

The equivalent Slurm script is:

```bash
#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=01:00:00
#SBATCH --job-name=test
#SBATCH --output=test.out
#SBATCH --error=test.err
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --mail-user=user@unm.edu

cd "$SLURM_SUBMIT_DIR"

python test.py
```

Submit the job with:

```bash
sbatch job_script.slurm
```

*This QuickByte was validated on 6/23/2026*
