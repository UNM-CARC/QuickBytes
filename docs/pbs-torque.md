# PBS/TORQUE
__Portable Batch System (PBS)__ is a computer software which performs job (a unit of work or unit of execution) computational resource allocation in an HPC center. PBS is often used in conjunction with UNIX cluster environments, i.e., software modules. There are multiple different versions of software that utilize PBS architecture, including TORQUE, which is the flavor of PBS we use at CARC.

 
__Terascale Open-source Resource and QUEue manager (TORQUE)__ is a job scheduler/resource manager that employs PBS. Jobs can be run either interactively or as a submitted PVS batch script that is run non-interactively and subsequently controlled through TORQUE. In both cases resources are requested and jobs submitted through TORQUE which then places your request into a queue.  


At CARC, all batch jobs are submitted through the machine’s head node via the PBS/TORQUE resource manager and are scheduled through the Maui scheduler.


### PBS Batch Scripts
To submit jobs at CARC you submit a PBS batch script to the TORQUE resource manager. This PBS script starts by telling TORQUE what kind of resources you are requesting for your job. These lines in your script start with `#PBS` followed by flags that specify things like wall time, nodes, and processors requested. To get a complete list of options available type `man qsub` from the command prompt when logged in to a CARC machine. 
After your PBS instructions to TORQUE, you then load your software modules (refer to the help page ‘Managing software modules’ for more information’) followed by software specific instructions. All PBS batch scripts take this same basic structure for job submission. For some example scripts refer to the help page ‘Example PBS Scripts’ to help you get started with computing at CARC. 
