## Using Orca on Wheeler and Taos

### Submitting an Orca script on Wheeler

Wheeler uses PBS (**P**ortable **B**atch **S**ystem) to submit jobs to the queue for execution. Below is an example script that can be used on Wheeler named `orca_submission.pbs`:

```bash
#!/usr/bin/bash

## Setup your qsub flags here requesting resources.
#PBS -l walltime=10:00:00
#PBS -l nodes=1:ppn=8
#PBS -N my_orca_job
#PBS -M <YourNetID>@unm.edu
#PBS -m bae

## Change to the submission directory 
## and load the Orca software module
cd $PBS_O_WORKDIR
module load orca/4.0.1

## Set your input file for Orca
input_file=my_orca_input.inp

# Orca needs the full path when running in parallel
full_orca_path=$(which orca)

# Run Orca
$full_orca_path $input_file
```

Now you can simply submit your Orca job to the queue with `qsub orca_submission.pbs`. 


### Submitting on Orca script on Taos

Taos uses Slurm (**S**imple **L**inux **U**tility for **R**esource **M**anagement) to submit jobs and manage resources. Slurm provides greater control over resource management and utilization which means one has to be more explicit in their submission script. Specifically, it is necessary to request sufficient memory for your task when submitting your job. Below is a sample script for submitting an Orca job on Taos named `orca_submission.sh`:

```bash
#!/usr/bin/bash

## Set your slurm flags here requesting resources.
#SBATCH --job-name=orca_test
#SBATCH --output=test.out
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
## This depends on which queue you have access to.
#SBATCH --partition=my_partition
#SBATCH --mem-per-cpu=6GB
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-type=fail         # send email if job fails
#SBATCH --mail-user=<YourNetID>@unm.edu

module load openmpi-3.1.5-gcc-5.4.0-f6ikvl6
module load orca/4.2.1

## Set your input and output file names
input_file=my_orca_input.inp
output_file=my_orca_output.log

# Set the scratch directory path
scratch_dir=/taos/scratch/$USER/

# Set the input and output paths on the scratch file system
output_scratch_path=$scratch_dir/$output_file
input_scratch_path=$scratch_dir/$input_file

# Copy the input file from the submission directory to the scratch directory
cp $SLURM_SUBMIT_DIR/$input_file $output_scratch_path

# Orca needs the full path when running in parallel
full_orca_path=$(which orca)

# Run Orca
$full_orca_path $input_scratch_path > $output_scratch_path

# Orca finished so copy the output file on scratch to the submission directory
cp $output_scratch_path $SLURM_SUBMIT_DIR/$output_file
```
Now you can simply submit your job to the queue with `sbatch orca_submission.sh`. 
