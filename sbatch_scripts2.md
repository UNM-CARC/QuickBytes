# Example Sbatch Scripts

### SLURM Hello World:
This example uses the "Bash" shell to print a simple "Hello World"
message. Note that the shell is specified with the `--shell` option. If you
do not specify a shell (either inside the Sbatch script or as an argument to `sbatch`),
then your default shell will be used.
Since this script uses built-in Bash commands no software modules are
loaded. That will be introduced in the next Sbatch script.

```bash
#!/bin/bash
## Introduction for writing an Sbatch script
## The next lines specify what resources you are requesting.
## Starting with 1 node, 8 processors per node, and 2 hours of walltime.
## Setup your sbatch flags
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --job-name=my_job
#SBATCH --mail-user=myemailaddress@unm.edu
#SBATCH --mail-type=BEGIN,END,FAIL
## All other instructions to SLURM are here as well and are preceded by #SBATCH, note that normal comments can also be preceded by a single #
## Change to directory the Sbatch script was submitted from
cd $SLURM_SUBMIT_DIR
## Print out a hello message indicating the host this is running on
export THIS_HOST=$(hostname)
echo Hello World from host $THIS_HOST
####################################################
```

Note that the `--ntasks-per-node` value must always be less than or equal
to the number of physical cores available on each node of the system on
which you are running and is machine specific. For example, on Easley,
`--ntasks-per-node` should be <=8, however, we recommend you always request
the maximum number of processors per node to avoid multiple jobs on one
node that have to share memory. For more information see CARC systems
information.

### Multi-processor example script:
```bash
#!/bin/bash
## Introductory Example
## Copyright (c) 2018
## The Center for Advanced Research Computing
## at The University of New Mexico
####################################################
## Setup your sbatch flags
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --job-name=my_job
#SBATCH --mail-user=myemailaddress@unm.edu
#SBATCH --mail-type=BEGIN,END,FAIL
# load the environment module to use OpenMPI built with the Intel compilers
module load openmpi-3.1.1-intel-18.0.2-hlc45mq
# Change to the directory where the Sbatch script was submitted from
cd $SLURM_SUBMIT_DIR
# run the command "hostname" on every CPU. Hostname prints the name of the computer it is running on.
# $SLURM_NTASKS is the total number of CPUs requested. In this case 1 node x 8 CPUs per node = 8
mpirun -np $SLURM_NTASKS hostname
####################################################
```

### Multi-node example script:
```bash
#!/bin/bash
## Introductory Example
## Copyright (c) 2018
## The Center for Advanced Research Computing
## at The University of New Mexico
####################################################
## Setup your sbatch flags
#SBATCH --time=2:00:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --job-name=my_job
#SBATCH --mail-user=myemailaddress@unm.edu
#SBATCH --mail-type=BEGIN,END,FAIL
# Change to directory the Sbatch script was submitted from
cd $SLURM_SUBMIT_DIR
# load the environment module to use OpenMPI built with the Intel compilers
module load openmpi-3.1.1-intel-18.0.2-hlc45mq
# print out a hello message from each of the processors on this host
# run the command "hostname" on every CPU. Hostname prints the name of the computer it is running on.
# $SLURM_NTASKS is the total number of CPUs requested. In this case 4 nodes x 8 CPUs per node = 32
# Since we are running on multiple nodes (computers) we have to tell mpirun the names of the nodes we were assigned. SLURM provides this automatically to mpirun when using srun, so we can simplify the command:
srun hostname
####################################################
```

*This quickbyte was validated on 6/9/2026*