# Example PBS Scripts

### PBS Hello World:

This example uses the "Bash” shell to print a simple “Hello World”
message. Note that it specifies the shell with the `-S` option. If you
do not specify a shell using the `-S` option (either inside the PBS
script or as an argument to `qsub`), then your default shell will be used.
Since this script uses built-in Bash commands no software modules are
loaded. That will be introduced in the next PBS script.

```bash
#!/bin/bash
## Introduction for writing a PBS script
## The next lines specify what resources you are requesting.
## Starting with 1 node, 8 processors per node, and 2 hours of walltime. 
## Setup your qsub flags
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=8
#PBS -N my_job
#PBS -M myemailaddress@unm.edu
#PBS -m bae
## All other instructions to TORQUE are here as well and are preceded by a single #, note that normal comments can also be preceded by a single #
## Specify the shell to be bash
#PBS -S /bin/bash
## Change to directory the PBS script was submitted from
cd $PBS_O_WORKDIR
## Print out a hello message indicating the host this is running on
export THIS_HOST=$(hostname)
echo Hello World from host $THIS_HOST
####################################################
```

Note that the `ppn` (processors per node) value must always be less than
or equal to the number of physical cores available on each node of the
system on which you are running and is machine specific. For example, on
Wheeler, `ppn` should be <=8, however, we recommend you always request
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
## Setup your qsub flags
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=8
#PBS -N my_job
#PBS -M myemailaddress@unm.edu
#PBS -m bae
# load the environment module to use OpenMPI built with the Intel compilers
module load openmpi-3.1.1-intel-18.0.2-hlc45mq 
# Change to the directory where the PBS script was submitted from
cd $PBS_O_WORKDIR
# run the command "hostname" on ever CPU. Hostname prints the name of the computer is it running on.
# $PBS_NP is the total number of CPUs requested. In this case 1 nodes x 8 CPUS per node = 8
mpirun -np $PBS_NP hostname
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
## Setup your qsub flags
#PBS -l walltime=2:00:00
#PBS -l nodes=4:ppn=8
#PBS -N my_job
#PBS -M myemailaddress@unm.edu
#PBS -m bae
# Change to directory the PBS script was submitted from
cd $PBS_O_WORKDIR
# load the environment module to use OpenMPI built with the Intel compilers
module load openmpi-3.1.1-intel-18.0.2-hlc45mq 
# print out a hello message from each of the processors on this host
# run the command "hostname" on ever CPU. Hostname prints the name of the computer is it running on.
# $PBS_NP is the total number of CPUs requested. In this case 4 nodes x 8 CPUS per node = 32
# Since we are running on multiple nodes (computers) we have to tell mpirun the names of the nodes we were assigned. Those names are in $PBS_NODEFILE.
mpirun -np $PBS_NP -machinefile $PBS_NODEFILE hostname
###################################################
```
