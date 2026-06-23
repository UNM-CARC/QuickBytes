### Cluster Profiles
To take advantage of MATLAB Parallel Server, we have set up a cluster profile specific to Easley.
All you need to do as a user is import the profile as a MATLAB command.
This can be done either in the MATLAB command window or in a MATLAB script.
The profile is located at the following path:
- Easley (General Queue): `/opt/local/MATLAB/easley-general.settings`

### Interactive Demo
If you would like to test MATLAB's parallel capabilities interactively, you can start an interactive session with the following:
```bash
easley:~$ srun --pty bash
```
Once you have a node allocated to you, load the MATLAB module and start a MATLAB session:
```bash
easley001:~$ module load matlab
easley001:~$ matlab
To get started, type doc.
For product information, visit [www.mathworks.com](https://www.mathworks.com).
>>
```
Now simply import the Easley cluster profile available in the root MATLAB folder:


profile = parallel.importProfile('/opt/local/MATLAB/easley-general.settings')


With the settings imported, you can now launch parallel pools for computation using the `easley` cluster profile. The code below is an example to test parallel computing using 16 'workers' on Easley while timing execution:


poolobj = parpool(profile, 16)

tic

n = 200

A = 500

a = zeros(1,n)

parfor i = 1:n

a(i) = max(abs(eig(rand(A))))

end % You may need to hit enter more than once to get the prompt back.

toc

delete(poolobj);


### Submitting a MATLAB job to the scheduler
Even better is to do everything using a batch script and avoid the mistakes associated with interactive computing. Below is an example MATLAB script named `parallel_matlab.m` that will import our cluster profile and compare the time of computation for a sequential for loop and a parallel for loop with 16 cores ('workers' in MATLAB speak).
#### MATLAB script
profile = parallel.importProfile('/opt/local/MATLAB/easley-general.settings')

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
#### Slurm script
Now the Slurm script we will call `parallel_matlab.slurm` to submit your sample MATLAB program:
```bash
#!/bin/bash
#SBATCH --job-name=parallel_matlab
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --output=parallel_matlab.out

cd $SLURM_SUBMIT_DIR
module load matlab
matlab -nodisplay -r parallel_matlab
```
Submit your Slurm script with `sbatch parallel_matlab.slurm` and hopefully all goes swimmingly. If you require assistance with MATLAB parallel computing, please send an email to help@carc.unm.edu.

*This QuickByte was validated on 6/23/2026.*
