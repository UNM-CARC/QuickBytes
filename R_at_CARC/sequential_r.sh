#!/bin/bash
#SBATCH --job-name r_sequential
#SBATCH --partition general
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 8
#SBATCH --time 00:30:00
#SBATCH --output r_sequential.out
#SBATCH --error r_sequential.err
#SBATCH --mail-type begin,end,fail
#SBATCH --mail-user my_name@unm.edu

cd $SLURM_SUBMIT_DIR

module load libdeflate/1.14-2pby r/4.5.2-pspo
export LD_LIBRARY_PATH=$LIBDEFLATE_LIB:$LD_LIBRARY_PATH

Rscript sequential.R
