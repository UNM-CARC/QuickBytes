# Parallel MATLAB batch submission

### Setting up the cluster profile
In order to submit a PBS script that takes advantage of MATLAB Parallel Server you first need to set up a new cluster profile specific to Wheeler. Thankfully this has already been done and all you need to do as a user is import the profile and that only needs to be done once. If you would like to do this interactively you can start an interactive session with the following:

```bash
wheeler-sn:~$ qsub -I -l walltime=01:00:00 -l nodes=1:ppn=8
```
Once you have a node allocated to you load the MATLAB module and start a MATLAB session:

```bash
wheeler001:~$ module load matlab/R2019a
wheeler001:~$ matlab -nodisplay

To get started, type doc.
For product information, visit www.mathworks.com.
>>
```
Now simply import the wheeler cluster profile availble in the root matlab folder:

```
>> parallel.importProfile('/opt/local/MATLAB/R2019a/wheeler.settings')
```
With the settings imported you can now launch parallel pools for computation using the `wheeler` cluster profile. The code below is an example to test parallel computing across two nodes on Wheeler while timing execution:

```
>> poolobj = parpool('wheeler', 16)
>> tic
>> n = 200
>> A = 500
>> a = zeros(1,n)
>> parfor i = 1:n
>> a(i) = max(abs(eig(rand(A))))
>> end
>> toc
>> delete(poolobj);
```
Even better is to do everything using a batch script and avoid the mistakes associated with interactive computing. Below is an example MATLAB script named `parallel_matlab.m` that will import our cluster profile and compare the time of computation for a sequential for loop and a parallel for loop with 16 cores ('workers' in MATLAB speak):

```
% If you have already set up your cluster profile you can comment or delete the following line
parallel.importProfile('/opt/local/MATLAB/R2019a/wheeler.settings')

poolobj = parpool('wheeler', 16);

tic
n = 200;
A = 500;
a = zeros(1,n);
for i 1:n;
    a(i) = max(abs(eig(rand(A))))
end
toc

tic
n = 200;
A = 500;
a = zeros(1,n);
parfor i 1:n;
    a(i) = max(abs(eig(rand(A))))
end
toc
delete(poolobj);
```
Now the PBS script we will call `parallel_matlab.pbs` to submit your sample MATLAB program:

```
#!/bin/bash

#PBS -N parallel_matlab
#PBS -l walltime=01:00:00
#PBS -l nodes=1:ppn=8
#PBS -j oe

cd #PBS_O_WORKDIR

module load matlab/R2019a

matlab -r -nodisplay parallel_matlab > parallel_matlab.out
```
Submit your PBS script with `qsub parallel_matlab.pbs` and hopefully all goes swimmingly. If you require assistance with MATLAB parallel computing please send an email to help@carc.unm.edu.
