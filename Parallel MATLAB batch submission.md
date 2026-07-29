# Parallel MATLAB batch submission

### Requesting cores with Slurm

To take advantage of MATLAB's parallel computing features on Easley, you request cores through Slurm as normal, then let MATLAB's own built-in local worker pool use them — there's no separate cluster profile to import. If you'd like to do this interactively you can start an interactive session with the following:

```bash
easley-sn:~$ srun --partition general --ntasks 1 --cpus-per-task 16 --pty bash
```

Once you have a node allocated to you, load the MATLAB module and start a MATLAB session:

```bash
easley021:~$ module load matlab/R2024b
easley021:~$ matlab
```

```
To get started, type doc.
For product information, visit www.mathworks.com.
>>
```

You can now launch a parallel pool sized to match the cores you requested from Slurm (16, in this example). The code below is an example to test parallel computing across those 16 cores while timing execution:

```
>> poolobj = parpool(16)
>> tic
>> n = 200;
>> A = 500;
>> a = zeros(1,n);
>> parfor i = 1:n
>>     a(i) = max(abs(eig(rand(A))));
>> end
>> toc
>> delete(poolobj);
```

Even better is to do everything using a batch script and avoid the mistakes associated with interactive computing. Below is an example MATLAB script named `parallel_matlab.m` that will compare the time of computation for a sequential for loop and a parallel for loop with 16 cores ('workers' in MATLAB speak):

```matlab
poolobj = parpool(16);

tic
n = 200;
A = 500;
a = zeros(1,n);
for i=1:n
    a(i) = max(abs(eig(rand(A))));
end
toc

tic
n = 200;
A = 500;
a = zeros(1,n);
parfor i=1:n
    a(i) = max(abs(eig(rand(A))));
end
toc
delete(poolobj);
```

Now the Slurm script we will call `parallel_matlab.sh` to submit your sample MATLAB program. Request the same number of `--cpus-per-task` as the worker count you pass to `parpool` in the script above:

```bash
#!/bin/bash

#SBATCH --job-name parallel_matlab
#SBATCH --partition general
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --time 00:10:00
#SBATCH --output parallel_matlab_job.out
#SBATCH --error parallel_matlab_job.err

cd $SLURM_SUBMIT_DIR

module load matlab/R2024b

matlab -nodisplay -r parallel_matlab > parallel_matlab.out
```

Submit your Slurm script with:

```bash
easley-sn:~$ sbatch parallel_matlab.sh
```

Real output from this exact script, comparing the sequential loop against the 16-worker `parfor` version:

```
Starting parallel pool (parpool) using the 'Processes' profile ...
Connected to parallel pool with 16 workers.
Elapsed time is 21.285930 seconds.
Elapsed time is 1.693033 seconds.
Parallel pool using the 'Processes' profile is shutting down.
```

If you require assistance with MATLAB parallel computing please send an email to help@carc.unm.edu.
