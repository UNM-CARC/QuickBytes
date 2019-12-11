# Writing and submitting the PBS script

## The PBS script
In order to actually submit a job to the cluster you need a PBS script that lists all of the resources you are requesting, the software you want to use, and the commands to that software. So pretend we have an R script called "my_script.R" that you want to run on Wheeler, the PBS script would look something like this:

```
#!/bin/bash

#PBS -N my_r_job
#PBS -l walltime=48:00:00
#PBS -l nodes=1:ppn=8
#PBS -j oe
#PBS -V
#PBS -m abe
#PBS -M my_name@unm.edu

cd $PBS_O_WORKDIR

module load r-3.6.0-gcc-7.3.0-python2-7akol5t

Rscript my_script.R
```
This PBS script would then be submitted to the job queue with 

```
yourusername@wheeler-sn$ qsub my_pbs_script.pbs
```

A PBS script is just a bash script that combines flags for the job scheduler (PBS), and bash commands. We can break it down by sections. 

### PBS directives

If you are unfamiliar with bash scripting the first line `#!/bin/bash/` is called the "hashbang" or "shebang" and is directing your shell on what should be used to interpret the following code. This isn't actually necessary for a PBS script but is just common practice. 

The next chunk of lines are the flags to `qsub` asking for specific resources. The `#` here are important because they represent comments to bash but are interpreted by `qsub`.

```
## The -N flag specifies the name of your job and will be what shows on the queue and the prefix for all 
## PBS specific output.
#PBS -N my_r_job

## The -l flag specifies the actual computational resources you want and can take many arguments. In this case we are 
## asking for 48 hours of walltime on the cluster with one node and all cpu's on that node, which for Wheeler is 8.
#PBS -l walltime=48:00:00
#PBS -l nodes=1:ppn=8

## The -j flag joins your standard out (stdout) and standard error (stderr) into one file. I do this just so there is 
## less output and clutter resulting from a job.
#PBS -j oe

## The -V flag exports user environmental variables from the head node to the compute node. Not always necessary.
#PBS -V

## The -m and -M flags specifiy how you want the scheduler to control mailing information about your job. The -m abe 
## is saying that you want emails for Abort, Begin, and End, and the -M flag is a comma separated list of who
## to send mail to. 
#PBS -m abe
#PBS -M my_name@unm.edu
```

At the very least you should always specify the walltime, nodes, and processors per node for each job. For an exhaustive list of `qsub` commands you can type `man qsub` on the head node of any CARC system. 

### Calling your code
The rest of the PBS script are usually bash commands (or whatever shell you prefer to use, which can be specified with the -S flag) that tells the compute node where your data is, loads the software you want, and then executes your job. 

```
## There are many job specific variables that are created when PBS starts a job, including $PBS_O_WORKDIR. The
## following line moves to the directory where the qsub command was executed.
cd $PBS_O_WORKDIR

## This loads the R software environment.
module load r-3.6.0-gcc-7.3.0-python2-7akol5t

## If you are using a conda environment instead of an R module installed by CARC you would have the following
module load anaconda3
source activate my_r_env

## This line is where you are actually running your R script. The older way of using R CMD BATCH is deprecated
## and Rscript is the preferred way for launching an R batch job.
Rscript my_script.R
```

