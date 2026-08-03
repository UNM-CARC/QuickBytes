# Writing and submitting the Slurm script

## The Slurm script
In order to actually submit a job to the cluster you need a Slurm script that lists all of the resources you are requesting, the software you want to use, and the commands to that software. So pretend we have an R script called "my_script.R" that you want to run on Easley, the Slurm script would look something like this:

```
#!/bin/bash

#SBATCH --job-name my_r_job
#SBATCH --partition general
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 8
#SBATCH --time 48:00:00
#SBATCH --output my_r_job.out
#SBATCH --error my_r_job.err
#SBATCH --mail-type begin,end,fail
#SBATCH --mail-user my_name@unm.edu

cd $SLURM_SUBMIT_DIR

module load libdeflate/1.14-2pby r/4.5.2-pspo
export LD_LIBRARY_PATH=$LIBDEFLATE_LIB:$LD_LIBRARY_PATH

srun Rscript my_script.R
```
This Slurm script would then be submitted to the job queue with 

```
yourusername@easley-sn$ sbatch my_slurm_script.sh
```

A Slurm script is just a bash script that combines flags for the job scheduler (Slurm), and bash commands. We can break it down by sections. See [pbs2slurm.md](../pbs2slurm.md) if you're converting an old PBS script and want the full flag-by-flag mapping.

### Slurm directives

If you are unfamiliar with bash scripting the first line `#!/bin/bash` is called the "hashbang" or "shebang" and is directing your shell on what should be used to interpret the following code. This isn't actually necessary for a Slurm script but is just common practice. 

The next chunk of lines are the flags to `sbatch` asking for specific resources. The `#` here are important because they represent comments to bash but are interpreted by `sbatch`.

```
## --job-name specifies the name of your job and will be what shows on the queue and the prefix for all
## Slurm specific output.
#SBATCH --job-name my_r_job

## --partition picks which queue your job runs in. "general" is the default queue most users have access to.
#SBATCH --partition general

## --nodes and --ntasks-per-node specify the actual computational resources you want. In this case we are
## asking for one node with all 8 cpus on that node.
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 8

## --time specifies the walltime you are requesting, in this case 48 hours.
#SBATCH --time 48:00:00

## --output and --error specify separate files for stdout and stderr. If you'd rather have them combined
## like PBS's old "-j oe" behavior, just point both flags at the same filename.
#SBATCH --output my_r_job.out
#SBATCH --error my_r_job.err

## --mail-type and --mail-user specify how you want the scheduler to control mailing information about your
## job. "begin,end,fail" means you want emails when the job starts, ends, and if it fails, and --mail-user
## is who to send mail to.
#SBATCH --mail-type begin,end,fail
#SBATCH --mail-user my_name@unm.edu
```

At the very least you should always specify the walltime, nodes, and tasks-per-node for each job. For an exhaustive list of `sbatch` options you can type `man sbatch` on the head node of any CARC system. 

### Calling your code
The rest of the Slurm script is usually bash commands, or whatever shell you prefer. The shell can be specified with the `--wrap` option or a different shebang. These commands tell the compute node where your data is, load the software you want, and then execute your job. 

```
## There are many job specific variables that are created when Slurm starts a job, including $SLURM_SUBMIT_DIR. The
## following line moves to the directory where the sbatch command was executed.
cd $SLURM_SUBMIT_DIR

## This loads the R software module.
module load libdeflate/1.14-2pby r/4.5.2-pspo
export LD_LIBRARY_PATH=$LIBDEFLATE_LIB:$LD_LIBRARY_PATH

## If you are using a conda environment instead of an R module installed by CARC you would have the following
## instead
module load miniconda3/latest
source activate my_r_env

## This line is where you are actually running your R script. The older way of using R CMD BATCH is deprecated
## and Rscript is the preferred way for launching an R batch job. Prefixing with srun ensures Slurm properly
## tracks and allocates the resources for this step.
srun Rscript my_script.R
```
