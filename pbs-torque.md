# Slurm

__Simple Linux Utility for Resource Management (Slurm)__ is a computer software which performs job (a unit of work or unit of execution) computational resource allocation in an HPC center. Slurm is widely used in HPC centers and clusters across the world, including at CARC, where it's the job scheduler and resource manager we use.

Jobs can be run either interactively or as a submitted Slurm batch script that is run non-interactively and subsequently controlled through Slurm. In both cases resources are requested and jobs submitted through Slurm, which then places your request into a queue.

At CARC, all batch jobs are submitted through the machine's head node via the Slurm resource manager and scheduler.

### Slurm Batch Scripts
To submit jobs at CARC you submit a Slurm batch script to the Slurm resource manager. This Slurm script starts by telling Slurm what kind of resources you are requesting for your job. These lines in your script start with `#SBATCH` followed by flags that specify things like wall time, nodes, and processors requested. To get a complete list of options available, type `man sbatch` from the command prompt when logged in to a CARC machine.

After your Slurm instructions, you then load your software modules (refer to the help page 'Managing software modules' for more information), followed by software specific instructions. All Slurm batch scripts take this same basic structure for job submission. For some example scripts, refer to the help page 'Example Slurm Scripts' to help you get started with computing at CARC.

*This QuickByte was validated on 6/22/2026*
