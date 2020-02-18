# Running MATLAB Jobs at CARC

### MATLAB
MATLAB is a powerful software environment and language especially for matrix manipulation and calculations, whence the name __MAT__rix__LAB__oratory. if you are unfamiliar with MATLAB please visit there website for more information at this [link](https://www.mathworks.com/products/matlab.html). For a list of which versions of MATLAB are available on a certain system use the command `module avail matlab` on the head node. MATLAB is installed on all CARC systems, however, it can only be accessed on the compute nodes and is not available on the head node. In order to run MATLAB jobs at CARC it is necessary to call the MATLAB software in batch mode to run on a script/program supplied by the user. 

### Batch mode

Many users are likely familiar with using the MATLAB GUI to run their code either in the interactive console or by launching a script. However, it is often useful to run a Matlab program from the command line in batch mode, as though it were a shell script. MATLAB can be run non-interactively using a built in function called batch mode. All MATLAB jobs should be run using batch mode when using CARC systems. 

### Submitting a job with batch mode

Say you have a small program named `my_program.m` that generates a 3x3 matrix of random numbers and writes the results to a .csv file. Your code for such a program might look like this:

```matlab
%generate a matrix of random numbers of dimension 3x3
rmatrix=rand(3);
fname='randnums.csv';
csvwrite(fname,rmatrix);
quit
```
This program can be submitted using batch mode with the command `matlab -r my_program`. In this command the `-r` flag is telling MATLAB to run your script `my_program.m` in batch mode. Notice that when calling a script with batch mode you leave off the extension `.m`. This command works if you are running on a local machine, however, when running jobs at CARC you need to submit your job to the job scheduler using a PBS script. For those unfamiliar with PBS scripts explanations and example scripts can be found [here](http://carc.unm.edu/user-support/using-carc-systems/running-jobs/sample-pbs-scripts.html). To submit our MATLAB program to the Wheeler job scheduler we would put our batch command in a PBS script similar to the one below:

```bash
#!/bin/bash

# Commands specific to the job scheduler requesting resources, naming your job, and setting up email alerts regarding job status.
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=8
#PBS -N my_matlab_job
#PBS -m abe
#PBS -M my_email.@unm.edu

# Change to the directory that you submitted your PBS script from.
cd $PBS_O_WORKDIR

# Loading the MATLAB software module. The specific module name is system dependent.
module load matlab/R2017a

# Calling MATLAB in batch mode to run your program. 
matlab -r -nojvm -nodisplay my_program > /dev/null
```

There are a couple of additions to our batch mode command when calling MATLAB on our program. Remember that the `-r` flag is telling MATLAB to run in batch mode. The `-nojvm` flag turns off Java Virtual Machine since this is only necessary when running the MATLAB GUI. The `-nodisplay` turns off all graphical output from MATLAB since we do not support visual display at CARC. At the end of our command we then redirect what would normally be written to `stdout`, or your MATLAB console when running interactively, to a special file called `null`. We do this because MATLAB normally writes all output to `stdout` which is stored in memory (RAM). If your program generates enough output to `stdout` this can overload local memory and crash the compute node that your program is running on. If you wish to keep what is printed to `stdout` you can redirect to a file instead using the following syntax and replacing the name with whatever you would like to call your file:

```bash
matlab -r -nojvm -nodisplay my_program > my_program.output
```
Now that you have your program and your PBS script you can submit your job to the job scheduler using the `qsub` command:

```bash
qsub my_matlab_job.pbs
```
