# Using GPUs with MATLAB

1. [Using a single GPU on Easley](#1)
     1. [Use GPU in Interactive Session](#1.1)
          1. [Identify and Select GPU](#1.1.1)
          2. [Using Arrays on GPU](#1.1.2)
          3. [Initialize Array](#1.1.3)
          4. [Test if array is on GPU](#1.1.4)
          5. [Retrieve Array from GPU](#1.1.5)
          6. [Use functions on GPU Arrays](#1.1.6)
     2. [Schedule a job](#1.2)
          1. [MATLAB Script](#1.2.1)
          2. [Slurm Script](#1.2.2)
          3. [Submit Job to Queue](#1.2.3)
2. [Using Multiple GPUs on a single Easley node](#2)
    1. [MATLAB Script](#2.1)
    2. [Slurm Script](#2.2)
    3. [Submit Job to Queue](#2.3)
3. [Using Multiple Nodes with their own GPUs](#3)


## Using a single GPU on Easley <a name="1"></a>

MATLAB allows the utilization of a single GPU that is part of a machine.
The following sections show how to access and utilize a GPU on Easley.

### Use GPU in Interactive Session <a name="1.1"></a>

First, we will open MATLAB in an interactive session on an Easley compute node. Easley's GPU partitions are `h100` and `l40s`, giving you H100 and L40S GPUs respectively. Request one with `--gres=gpu:<type>:<count>`.

#### Identify and Select GPU <a name="1.1.1"></a>

Start by requesting an interactive session:

```bash
easley-sn:~$ srun --partition l40s --gres=gpu:l40s:1 --pty bash
```

Once you have a node allocated to you, load the MATLAB module and start a MATLAB session:

```bash
easley055:~$ module load matlab/R2024b
easley055:~$ matlab
```

```
To get started, type doc.
For product information, visit www.mathworks.com.
>>
```

Now you can check to see the number of GPUs available:
```
>> gpuDeviceCount("available")
```
You should see the following:
```
ans = 
     1
```
This means that you have access to a single GPU.

To get information about the available gpus, use this function:
```
>> gpuDeviceTable
```
That will print something that looks like this on Easley:
```
ans =

  1x5 table

    Index        Name         ComputeCapability    DeviceAvailable    DeviceSelected
    _____    _____________    _________________    _______________    ______________

      1      "NVIDIA L40S"          "8.9"               true              false
```

Next, you can tell MATLAB which GPU to use. Pass in the desired index from the above table.
If you do not do this, MATLAB will automatically grab the lowest index GPU when you try to use one.
```
>> gpuDevice(1)
```

Running the `gpuDeviceTable` command again shows this change:
```
>> gpuDeviceTable
```

```
ans =

  1x5 table

    Index        Name         ComputeCapability    DeviceAvailable    DeviceSelected
    _____    _____________    _________________    _______________    ______________

      1      "NVIDIA L40S"          "8.9"               true              true
```

#### Using Arrays on GPU <a name="1.1.2"></a>

In order to utilize the GPU, data must be loaded into a `gpuArray` object.
For a full description of the `gpuArray` object, please visit the official MathWorks Documentation at [https://www.mathworks.com/help/parallel-computing/gpuarray.html](https://www.mathworks.com/help/parallel-computing/gpuarray.html)

##### Initialize Array <a name="1.1.3"></a>
First, create a normal array using any method you like.
In this example we will use the `magic(8)` function to create a magic square matrix that is 8x8.
```
>> A = magic(8)
```
Next, pass that into a `gpuArray` object.
This will copy the contents of a normal array into an array on the GPU.
```
>> B = gpuArray(A)
```

##### Test if array is on GPU <a name="1.1.4"></a>
The `isgpuarray` function tests if an array is on a GPU:
```
>> isgpuarray(A)
```

```
ans =

  logical

   0
```

```
>> isgpuarray(B)
```

```
ans =

  logical

   1
```
This confirms that array A is not on the GPU, but array B is.

##### Retrieve Array from GPU <a name="1.1.5"></a>
In order to retrieve an array from the GPU and put it back in the MATLAB workspace, use the `gather` function.
It will copy the contents of an array on the GPU into a normal array.
This is neccesary if you want to to perform non-GPU actions on your data after using the GPU.
```
>> C = gather(B)
```
Now, we can test to see if C is stored on the gpu:
```
>> isgpuarray(C)
```

```
ans =

  logical

   0
```

#### Use functions on GPU Arrays <a name="1.1.6"></a>
To perform functions on `gpuArray` objects, use the `arrayfun` function.
In this example, we will apply the MATLAB `sqrt` function to the array (B) that we created in the previous step:
```
result = arrayfun(@sqrt,B)
```
This will apply the `sqrt` function to every element in the GPU array.
`result` is also a GPU array:
```
>> isgpuarray(result)
```

```
ans =

  logical

   1
```

To see a list of MATLAB functions that are supported using gpus, visit [https://www.mathworks.com/help/parallel-computing/gpuarray.html](https://www.mathworks.com/help/parallel-computing/gpuarray.html)

You can also create your own functions to pass into `arrayfun`.

### Schedule a job <a name="1.2"></a>
It is good idea to do everything using a batch script and avoid the mistakes associated with interactive computing.
To get an idea of why performing functions on `gpuArray` objects is a good idea, let's create a simple MATLAB script that displays the amount of time it takes to perform the same computation on a cpu and on a gpu.
We will then create a Slurm script that schedules a job with a GPU to run the MATLAB script for us.


#### MATLAB Script <a name="1.2.1"></a>
We will perform the `sqrt` function on a 5000x5000 array.
The use of `tic` and `toc` allow us to time the seperate applications of `sqrt`.

Create the following script with the name `gpu_matlab.m`:

```matlab
gpuDevice(1);

A = magic(5000);
disp("sqrt of 5000x5000 matrix on cpu:")
tic
B = arrayfun(@sqrt, A);
toc
disp("sqrt of 5000x5000 matrix on gpu:")
C = gpuArray(magic(5000));
tic
D = arrayfun(@sqrt,C);
toc
```

#### Slurm Script <a name="1.2.2"></a>

Now, let's create a Slurm script called `gpu_matlab.sh`.
Replace the `<DIR>` with the path to the directory containing the MATLAB script created above.
This script will request the desired resources, load the MATLAB module, then run the script.
The output of the script will be sent to the file: `gpu_matlab.out`

```bash
#!/bin/bash

#SBATCH --job-name gpu_matlab_job
#SBATCH --output gpu_matlab_job.out
#SBATCH --error gpu_matlab_job.err
#SBATCH --time 00:05:00
#SBATCH --partition l40s
#SBATCH --ntasks 1
#SBATCH --gres=gpu:l40s:1

cd <DIR>

module load matlab/R2024b
matlab -nodisplay -r gpu_matlab > gpu_matlab.out
```


#### Submit Job to Queue <a name="1.2.3"></a>

Now we can submit the job to the scheduler from the Easley head node:

```bash
easley-sn:~$ sbatch gpu_matlab.sh
```

View the results:
```bash
easley-sn:~$ cat gpu_matlab.out
```

Real output from this exact script, comparing a 5000x5000 `sqrt` on CPU vs. a single L40S GPU:
```
sqrt of 5000x5000 matrix on cpu:
Elapsed time is 13.255715 seconds.
sqrt of 5000x5000 matrix on gpu:
Elapsed time is 0.355405 seconds.
```

## Using Multiple GPUs on a single Easley node <a name="2"></a>

Easley's `l40s` partition has nodes with up to four L40S GPUs.
MATLAB allows for the utilization of multiple GPUs on a single node in the same way you use multiple CPUs.
To show how this works, below is an example MATLAB script that will create a logistic map using all available GPU's on the assigned node.

The `parpool` object is used to create workers to parallelize the execution.
Each worker will grab it's own GPU when performing actions with `gpuArray` objects.
For this to work properly, ensure that you have been allocated an equal number of CPUs as GPUs on the machine.
An example slurm script is included below to give an idea of how to ask for the proper resources to be allocated.

### MATLAB Script <a name="2.1"></a>

Create the following MATLAB script called `gpu_logistic_map.m`
This simple MATLAB script creates a Logistic Map by iterating the logistic equation on a set of random populations.
A worker is created for each available GPU.
They will then split up the work performed in the `parfor` loop.
The result is a logistic map figure saved as 'logistic_map.jpg'
It also contains calls to time the execution of the `parfor` loop.


```matlab
N = 1000;
r = gpuArray.linspace(0,4,N);

numIterations = 1000;

numGPUs = gpuDeviceCount("available");
parpool(numGPUs);

numSimulations = 100;
X = zeros(numSimulations,N,'gpuArray');

disp("Timing execution of parfor loop:")

tic
parfor i=1:numSimulations
  X(i,:) = rand(1,N,'gpuArray')
  for n=1:numIterations
    X(i,:) = r.*X(i,:).*(1-X(i,:));
  end
end
toc

f = figure('visible','off');
plot(r,X,'.');
saveas(f,'logistic_map','jpg')

return
```

### Slurm Script <a name="2.2"></a>

Request as many GPUs as you want to use with `--gres=gpu:l40s:<count>`, and match `--cpus-per-task` to that same count, since MATLAB uses a CPU to access each GPU. For two GPUs, ask for two CPUs and two GPUs.

Create the following slurm script called `gpu_logistic_map.sh`.
Replace the `<DIR>` with the path to the directory containing the MATLAB script created above.
This script will ask the scheduler for the proper resources.
Once the resources are allocated, the script will run the MATLAB script from the above step.
The MATLAB script will create a .jpg image once it has finished.
Any output of the MATLAB script is redirected to `gpu_logistic_map.out`.

```bash
#!/bin/bash

#SBATCH --job-name gpu_logistic_map_job
#SBATCH --output gpu_logistic_map_job.out
#SBATCH --error gpu_logistic_map_job.err
#SBATCH --time 00:10:00
#SBATCH --partition l40s
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --gres=gpu:l40s:2

cd <DIR>

module load matlab/R2024b
matlab -nodisplay -r gpu_logistic_map > gpu_logistic_map.out
```

### Submit Job to Queue <a name="2.3"></a>

Now we can submit the job to the scheduler from the Easley head node:
```bash
easley-sn:~$ sbatch gpu_logistic_map.sh
```
View the results:
```bash
easley-sn:~$ cat gpu_logistic_map.out
```

You can also view the `logistic_map.jpg` image using your preferred method.


## Using Multiple Nodes with their own GPUs <a name="3"></a>

Coming Soon!
