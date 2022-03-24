This tutorial contains instructions for compiling and running the SimCov immunology model on the Wheeler cluster.

## Download the SimCov Source Code from GitHub

Change directory to your home: 
```
cd ~
```
Clone the simcov Github repository into your home directory:
```
git clone --recurse-submodules https://github.com:AdaptiveComputationLab/simcov.git
```

## Build SimCov from Source
Load Wheeler modules and set UPCXX variables (NOTE: modules subject to change use 'module spider' to find availability):
```
export UPCXX_THREADMODE=seq
export UPCXX_CODEMODE=opt
module load gcc/11.2.0-otgt
module load cmake/3.22.2-c2dw
module load upcxx/2021.9.0-r4of
```
Run the build script:
```
cd simcov
./build.sh Release
```
## Configure SimCov 
The config files are in ~/simcov and end with ".config". You can edit them with a text editor.

## Submit a SimCov Job 
A wheeler PBS script is provided for you. We have submitted the script below to the simcov developers - so hopefully by the time you pull simcov the code below will already be in the wheeler_simcov_run.pbs. If not update the script to contain the following: 
 
This PBS submission script will run simcov on a compute node using covid_default.config:
```
#!/bin/bash

#PBS -q normal
#PBS -l nodes=2:ppn=8
#PBS -l walltime=01:00:00
#PBS -N simcov_test
#PBS -j oe

module load gcc/11.2.0-otgt
module load upcxx/2021.9.0-r4of
module load cmake/3.22.2-c2dw

cd $PBS_O_WORKDIR

upcxx-run -n $PBS_NP -N $PBS_NUM_NODES -- install/bin/simcov --config=covid_default.config --output=results
``` 
To run simcov on a compute node enter
```
qsub wheeler_simcov_run.pbs
```

Outputs will be in a results folder by default
