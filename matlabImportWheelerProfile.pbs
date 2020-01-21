#!/bin/bash

#PBS -N matlabImportProfile
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=1
#PBS -j oe

cd #PBS_O_WORKDIR

# Load matlab R2019a
module load matlab/R2019a

# Import the global profile for Wheeler to your home profile

matlab -nodisplay -nodesktop -r "wheeler=parallel.importProfile('/opt/local/MATLAB/R2019a/wheeler.settings')"
