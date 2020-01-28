# Example PBS Scripts

### PBS Hello World:

This example uses the "Bash” shell to print a simple “Hello World”
message. Note that it specifies the shell with the `-S` option. If you
do not specify a shell using the `-S` option (either inside the PBS
script or as an argument to `qsub`), then your default shell will be used.
Since this script uses built-in Bash commands no software modules are
loaded. That will be introduced in the next PBS script.

```bash
## Introduction for writing a PBS script
## Copyright (c) 2018 The Center for Advanced Research Computing
## The University of New Mexico
####################################################
## The next lines specify what resources you are requesting.
## Starting with 1 node, 8 processors per node, and 48 hours of walltime. 
#PBS -lnodes=1:ppn=8
#PBS -lwalltime=48:00:00
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
#PBS -lnodes=1:ppn=8
#PBS -lwalltime=1:00
# load the environment module to use OpenMPI built with the Intel compilers
module load openmpi-3.1.1-intel-18.0.2-hlc45mq 
# Change to the directory where the PBS script was submitted from
cd $PBS_O_WORKDIR
# print out a hello message from each of the processors on this host
# indicating the host this is running on
export THIS_HOST=$(hostname)
mpirun -np 8 -machinefile $PBS_NODEFILE echo Hello World from host $THIS_HOST
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
#PBS -lnodes=2:ppn=8
#PBS -lwalltime=1:00
# Change to directory the PBS script was submitted from
cd $PBS_O_WORKDIR
# load the environment module to use OpenMPI built with the Intel compilers
module load openmpi-3.1.1-intel-18.0.2-hlc45mq 
# print out a hello message from each of the processors on this host
# indicating the host this is running on
export THIS_HOST=$(hostname)
mpirun -np 16 -machinefile $PBS_NODEFILE echo Hello World from host $THIS_HOST
###################################################
```
