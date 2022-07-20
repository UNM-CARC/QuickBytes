# Parallel MATLAB batch submission

### Cluster Profiles

To take advantage of MATLAB Parallel Server, we have setup cluster profiles specific to the Wheeler, Xena, and Hopper clusters. 
All you need to do as a user is import the profile of the cluster you are using as a MATLAB command.
This can be done either in the MATLAB command window or in a MATLAB script.

Each profile is located at the following path:

- Wheeler (Normal Queue): `/opt/local/MATLAB/wheeler-normal.setting`
- Wheeler (Debug Queue): `/opt/local/MATLAB/wheeler-debug.settings`
- Xena (Single GPU Queue): `/opt/local/MATLAB/xena-singleGPU.settings`
- Xena (Dual GPU Queue): `/opt/local/MATLAB/xena-dualGPU.settings`
- Hopper (General Queue): `/opt/local/MATLAB/hopper-general.settings`


### Interactive Demo

If you would like to do test MATLAB's parallel capabilities interactively you can start an interactive session with the following (note that this example is done on wheeler, but it can be done using any of the above cluster profiles on their res:


```bash
wheeler:~$ srun --pty bash
```
Once you have a node allocated to you load the MATLAB module and start a MATLAB session:

```bash
wheeler001:~$ module load matlab
wheeler001:~$ matlab

To get started, type doc.
For product information, visit www.mathworks.com.
>>
```
Now simply import the wheeler cluster profile (or the profile that corresponds to the cluster you are on, if not wheeler) availble in the root matlab folder:

```
>> profile = parallel.importProfile('/opt/local/MATLAB/wheeler-normal.settings')
```
With the settings imported you can now launch parallel pools for computation using the `wheeler` cluster profile. The code below is an example to test parallel computing using 16 'workers' on Wheeler while timing execution:

```
>> poolobj = parpool(profile, 16)
>> tic
>> n = 200
>> A = 500
>> a = zeros(1,n)
>> parfor i = 1:n
>> a(i) = max(abs(eig(rand(A))))
>> end % You may need to hit enter more than once to get the prompt back.
>> toc
>> delete(poolobj);
```

### Submitting a MATLAB job to the scheduler

Even better is to do everything using a batch script and avoid the mistakes associated with interactive computing. Below is an example MATLAB script named `parallel_matlab.m` that will import our cluster profile and compare the time of computation for a sequential for loop and a parallel for loop with 16 cores ('workers' in MATLAB speak).

#### MATLAB script

```
profile = parallel.importProfile('/opt/local/MATLAB/wheeler-normal.settings')

poolobj = parpool(profile, 16);

tic
n = 200;
A = 500;
a = zeros(1,n);
for i=1:n;
    a(i) = max(abs(eig(rand(A))))
end
toc

tic
n = 200;
A = 500;
a = zeros(1,n);
parfor i=1:n;
    a(i) = max(abs(eig(rand(A))))
end
toc
delete(poolobj);
```

#### PBS Script

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


