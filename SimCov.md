This tutorial contains instructions for compiling and running the SimCov immunology model on the Hopper cluster.

## Download the SimCov Source Code from GitHub

Change directory to your home: 
```
cd ~
```
Clone the simcov Github repository into your home directory:
```
git clone --recurse-submodules https://github.com/AdaptiveComputationLab/simcov.git
```

## Build SimCov from Source
Load Hopper modules and set UPCXX variables (NOTE: modules subject to change use 'module spider' to find availability). UPC++ is currently only available as a module on Hopper, not Easley, so this needs to run on Hopper:
```
export UPCXX_THREADMODE=seq
export UPCXX_CODEMODE=opt
module load gcc/8.5.0-lpgx
module load cmake/3.31.6-qm2s
module load upcxx/2022.3.0-yrwd
module load openmpi/3.1.6-qpl3
export CXX=$(which mpic++)
```
Run the build script:
```
cd simcov
./build.sh Release
```
## Configure SimCov 
The config files are in ~/simcov and end with ".config". You can edit them with a text editor.

## Submit a SimCov Job 
This Slurm submission script will run simcov on a compute node using covid_default.config:
```
#!/bin/bash

#SBATCH --job-name simcov_test
#SBATCH --partition general
#SBATCH --nodes 2
#SBATCH --ntasks-per-node 8
#SBATCH --time 01:00:00
#SBATCH --output simcov_test.out
#SBATCH --error simcov_test.err

module load gcc/8.5.0-lpgx
module load upcxx/2022.3.0-yrwd
module load cmake/3.31.6-qm2s

cd $SLURM_SUBMIT_DIR

upcxx-run -n $SLURM_NTASKS -N $SLURM_NNODES -- install/bin/simcov --config=covid_default.config --output=results
``` 
To run simcov on a compute node enter
```
sbatch hopper_simcov_run.sh
```

Outputs will be in a results folder by default
