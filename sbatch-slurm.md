# SLURM
**Simple Linux Utility for Resource Management (SLURM)** is a computer software which performs job (a unit of work or unit of execution) computational resource allocation in an HPC center. SLURM is often used in conjunction with UNIX cluster environments, i.e., software modules. SLURM is the job scheduler/resource manager we use at CARC.

Jobs can be run either interactively using `srun` or as a submitted Sbatch script that is run non-interactively and subsequently controlled through SLURM. In both cases resources are requested and jobs submitted through SLURM which then places your request into a queue.

At CARC, all batch jobs are submitted through the machine's head node via the SLURM resource manager and are scheduled through the SLURM scheduler.

## Sbatch Scripts
To submit jobs at CARC you submit an Sbatch script to the SLURM resource manager. This script starts by telling SLURM what kind of resources you are requesting for your job. These lines in your script start with `#SBATCH` followed by flags that specify things like wall time, nodes, and processors requested. To get a complete list of options available type `man sbatch` from the command prompt when logged in to a CARC machine.

After your SLURM instructions, you then load your software modules (refer to the help page 'Managing software modules' for more information) followed by software specific instructions. All Sbatch scripts take this same basic structure for job submission. For some example scripts refer to the help page 'Example Sbatch Scripts' to help you get started with computing at CARC.

*This quickbyte was validated on 6/9/2026*
