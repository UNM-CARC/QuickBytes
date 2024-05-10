# GNU Parallel #
GNU parallel enables us to run as many jobs in parallel instead of sequentially thus saving lots of time. Unlike creating a queue for exectution of processes in a sequential run, GNU parallel tends to maximally parallize the execution over available processors in an embarassingly parallel fashion.

For example, a parallel command to change formats of all files with csv extension to .txt using gnu-parallel is presented. 
      module load image-magick-7.0.5-9-gcc-4.8.5-python2-xzyy5cz
      $find . -name "*csv" | parallel -I% --max-args 1 convert % %.txt

Here the command finds all the files with .csv extension first and parallely converts them to txt format .

Similarly, parallel can also used to compressed as many files and decompress them.

     $parallel gzip ::: *.txt
     $parallel gunzip ::: *.gz
  
Tha above two commands can be used to zip and unzip image files with .jpg exptesion over given path. 



## Matlab Implementation of GNU Parallel ##



GNU Parallel takes many different arguments, but here we will use only two, --arg-file and {}. --arg-file precedes an input file name, “msizes”, and {} is replaced with each line of the input file. A different copy of Matlab is run simultaneously, with each line of the input file replacing {} in each copy. This is Matlab in high-throughput mode (on a single node). Here is the new “parallel matlab” command:

	parallel --arg-file msizes ‘matlab –nojvm –nodisplay –r “msize={};program”' >/dev/null 

Single quotes are required around the Matlab portion of the parallel Matlab command. The actual Matlab code is enclosed in double quotes. The contents of the input file, msizes, is:

	1
	2
	3
	4

This creates four files: 1.csv, 2.csv, 3.csv, and 4.csv. The contents of the files are, e.g., 1.csv:

	0.81472

3.csv:

	0.81472,0.91338,0.2785
	0.90579,0.63236,0.54688
	0.12699,0.09754,0.95751

So far, the command has run Matlab in high-throughput mode on only a single node, a node that you are currently logged into. This is not how Matlab should typically be run at CARC, since it is not taking advantage of the Center's large-scale resources. To run Matlab in high-throughput mode on massively-parallel or cluster machines, it is necessary to use a PBS batch script on the head node of a CARC machine, and have the script run Matlab for you. Use of a PBS batch script allows you to run on many nodes at the same time. Before we use a PBS batch script we will need to make some changes to the program.m and parallel Matlab command. The program.m now reads:

	%generate a matrix of random numbers of dimension msize x msize
	rmatrix=rand(msize);
	%create an output file name based on msize and write the random matrix to it
	fname=num2str(msize);
	process=num2str(pid);
	fname=strcat(process,'.',fname,'.csv');
	csvwrite(fname,rmatrix);
	quit

The parent process id is now prepended to the file name. This is helpful because there will now be multiple output files, and they must all have unique names. The command to run Matlab is now:
		
	parallel -j0 --arg-file msizes 'matlab -nojvm -nodisplay -r "msize={};pid=$PPID;program"' >/dev/null

The $PPID (parent process id#) is input to program.m as the pid variable. The -j0 flag ensures that as many cores as possible on the node are used. Running this command (just as an example, without the PBS batch file) would produce output files: 
	 
        18778.1.csv 18778.2.csv 18778.3.csv 18778.4.csv.

The contents are the same as before. The command (with some PBS specific modifications) can now be inserted into a PBS batch script in order to run on more than one node, i.e. in high throughput mode.
High-Throughput Mode

To generalize the command to run on CARC machines and allow the use of multiple nodes on those machines, a PBS batch script is necessary. This will allocate nodes and the cores on each node to execute the parallel Matlab command. A sample PBS script reads:

	#PBS -l nodes=4:ppn=2
	#PBS -l walltime=00:10:00
	#PBS -N matlab_test
	#PBS -S /bin/bash
	cd $PBS_O_WORKDIR
	source /etc/profile.d/modules.sh
	module load matlab
	module load gnu-parallel
	PROCS=$(cat $PBS_NODEFILE | wc -l)
	nname=`hostname -s`
	echo starting Matlab jobs at `date`
	parallel -j0 --sshloginfile $PBS_NODEFILE --workdir $PBS_O_WORKDIR --env PATH --arg-file msizes 'matlab -nojvm -nodisplay -r "msize={};pid=$$;program" >/dev/null'
	echo finished Matlab jobs at `date`

The essential portion for running Matlab in high-throughput mode is embodied in the first line, “nodes=4:ppn=2”. It is very important to remember to allocate the correct number of cores with this line. Use this equation to calculate the number of cores you are allocating: nodes x ppn = number of cores allocated. But since you must also match the number of lines of input in msizes (which determines the number of Matlab processes run) to the number of cores allocated, the equation should really be: nodes x ppn = number of cores allocated = number of lines of input = number of Matlab processes run. If you run more Matlab processes than the number of cores you allocate, the job will run much more slowly, e.g. allocating 8 cores and running 9 Matlab jobs will cause the overall job to take twice as long as when running 8 Matlab jobs. Running fewer Matlab jobs than the number of cores allocated leaves cores unused (and unusable by other users for the duration of your job) and so wastes resources. You always want the number of cores allocated to equal the number of Matlab jobs run (which is the number of lines in the file msizes). The scripts can be modified of course, but this principle should always be kept in mind. Also keep in mind also that the “ppn” in the first line of the PBS script will vary from machine to machine, and you will get an error if it is incorrectly specified, i.e. some machines have more cores per node than others. For a list of CARC resources and information on numbers of processors/node, see Systems. Here are the contents of program.m:

	%generate a matrix of random numbers of dimension msize x msize
	rmatrix=rand(msize);
	%create a unique output name based on the node hostname, process id#,
	%and msize and write the random matrix to it
	[~,hname]=system('hostname');
	fname=num2str(msize);
	process=num2str(pid);
	fname=strcat(hname,'.',process,'.',fname,'.csv');
	csvwrite(fname,rmatrix);
	quit

Here are the contents of msizes:

	1
	2
	3
	4
	5
	6
	7
	8

The PBS script above allocates 8 cores from a machine with 2 cores per node. You’ll notice there have been some changes to the parallel Matlab command now that it is being used in a PBS script. It now reads:

	parallel -j0 --sshloginfile $PBS_NODEFILE --workdir $PBS_O_WORKDIR --env PATH --arg-file msizes 'matlab -nojvm -nodisplay -r "msize={};pid=$$;program" >/dev/null'

You’ll notice that a number of flags have been added. The flag “--sshloginfile $PBS_NODEFILE” gives the parallel command the hostnames of all the nodes that the PBS script has allocated for the job. (The names of the nodes are contained in the PBS environment variable $PBS_NODEFILE.) The flag “--workdir $PBS_O_WORKDIR” uses another PBS environment variable to force Matlab to run in the directory where the PBS script was run. The flag “--env PATH” makes sure all the Matlab processes have the same environment variables as the PBS script has when it is running, e.g. those variables loaded with “module” commands. Notice how this variable does not get a dollar sign ($) in front of it. GNU parallel understands this particular flag without the dollar sign. The rest of the command remains the same.
Submitting the Job

To run this job, save the PBS script to a file, e.g. mtest_pbs. Submit the job to the PBS batch scheduler by typing: qsub mtests_pbs. You should get, in this example, 8 output files containing random numbers. Each file will have a matrix of random numbers of size 1x1, 2x2, 3x3, …, and 8x8. There should also be a .o and .e file, e.g. matlab_test.e27704. This will contain the standard output and standard error of your job, including messages from both Matlab and the PBS queuing system. Due to the way the software works, sometimes Matlab’s error output will actually go into the .o file. The error output of PBS will always go to the .e file.




## Example of running embarassingly parallel jobs in python with parallel
The usage of gnu-parallel for python tasks is similar to that of matlab. Following are the sample codes showing implementation of gnu-parallel for python tasks. 

### Code for PBS script
	#!/bin/bash
	#PBS -N Gnu_parallel_test
	#PBS -l nodes=2:ppn=4
	#PBS -l walltime=01:00:00


	# load GNU-parallel module
	module load parallel-20170322-intel-18.0.2-4pa2ap6

	# load anaconda python
	module load anaconda

	# activate python environment
	source activate numpy_py3   #you need to have numpy_py3 environment with numpy installed. Refer to Anaconda quickbytes. 

	# change to directory PBS script was submitted. 
	cd $PBS_O_WORKDIR

	# set jobs per node, which is core per node for galles
	JOBSPERNODE=8

	/usr/bin/time -o time.log parallel --joblog logfile --wd $PBS_O_WORKDIR -j $JOBSPERNODE --sshloginfile $PBS_NODEFILE --env PATH -a mat_in python matrix_inv.py

### code for matrix_inv.py file
	# Import Libraries
	import numpy
	from numpy import linspace
	from numpy.random import rand
	from numpy.linalg import inv
	import timeit
	import argparse


	# define command line inputs
	parser = argparse.ArgumentParser()
	parser.add_argument("matrix", type=int, help='provide single integer for matrix')
	args = parser.parse_args()
	#define our matrix inverse function

	def matinv(x):
	        mat = rand(x, x)
	        b = inv(mat)
	        return b
	out = matinv(args.matrix)
	numpy.savetxt("%d.csv" % args.matrix, out, delimiter=",")



### The Contents of mat_in looks like
	1000
	2000
	3000
	4000
	5000
	6000
	7000
	8000



