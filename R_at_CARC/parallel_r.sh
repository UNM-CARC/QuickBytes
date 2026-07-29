#!/bin/bash
#SBATCH --job-name r_parallel
#SBATCH --partition debug
#SBATCH --nodes 2
#SBATCH --ntasks-per-node 8
#SBATCH --time 00:10:00
#SBATCH --output job.out
#SBATCH --error job.err
#SBATCH --mail-type begin,end,fail
#SBATCH --mail-user my_name@unm.edu

cd $SLURM_SUBMIT_DIR

module load parallel
module load libdeflate/1.14-2pby r/4.5.2-pspo
export LD_LIBRARY_PATH=$LIBDEFLATE_LIB:$LD_LIBRARY_PATH

NUMTAXA=$(seq 20 5 100)

# parallel execution across every node in the allocation
parallel --joblog job.log -j "$SLURM_NTASKS_PER_NODE" --sshloginfile "$CARC_NODEFILE" --env PATH --env LD_LIBRARY_PATH --workdir "$SLURM_SUBMIT_DIR" --colsep ' ' 'Rscript parallel.r {1} {2} {3}' :::: parameters ::: $NUMTAXA
