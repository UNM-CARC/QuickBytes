# Using GPUs with MATLAB

## Using a single GPU on Easley

MATLAB allows using a single GPU independently of the rest of the cluster.
The following sections show how to access and utilize a GPU on Easley.

### Use GPU in Interactive Session

First, we will open MATLAB in an interactive session on an Easley compute node.

#### Identify and Select GPU

Start by requesting an interactive session:

```bash
easley:~$ srun -G 1 --pty bash
```

Once you have a node allocated to you, load the MATLAB module and start a MATLAB session:

```bash
easley01:~$ module load matlab
easley01:~$ matlab

To get started, type doc.
For product information, visit www.mathworks.com.
>>
```

Now you can check to see the number of GPUs available:
```bash
>> gpuDeviceCount("available")
```
You should see the following:
```bash
ans = 
     1
```
This means that you have access to a single GPU.

To get information about the available GPUs, use this function:
```bash
>> gpuDeviceTable
```
That will print something that looks like this on Easley:
```bash
ans =

  1x5 table

    Index        Name        ComputeCapability    DeviceAvailable    DeviceSelected
    _____    ____________    _________________    _______________    ______________

      1      "<GPU model>"          "<compute capability>"               true              false
```

Next, you can tell MATLAB which GPU to use (pass in the desired index from the above table).
If you do not do this, MATLAB will automatically grab the lowest-index GPU when you try to use one.
```bash
>> gpuDevice(1)
```

Running the `gpuDeviceTable` command again shows this change:
```bash
>> gpuDeviceTable

ans =

  1x5 table

    Index        Name        ComputeCapability    DeviceAvailable    DeviceSelected
    _____    ____________    _________________    _______________    ______________

      1      "<GPU model>"          "<compute capability>"               true              true

```

#### Using Arrays on GPU

In order to utilize the GPU, data must be loaded into a `gpuArray` object.
For a full description of the `gpuArray` object, please visit the official MathWorks Documentation at [https://www.mathworks.com/help/parallel-computing/gpuarray.html](https://www.mathworks.com/help/parallel-computing/gpuarray.html)

##### Initialize Array
First, create a normal array using any method you like.
In this example, we will use the `magic(8)` function to create an 8x8 magic square matrix.
```bash
>> A = magic(8)
```
Next, pass that into a `gpuArray` object.
This will copy the contents of a normal array into an array on the GPU.
```bash
>> B = gpuArray(A)
```

##### Test if array is on GPU
The `isgpuarray` function tests if an array is on a GPU:
```bash
>> isgpuarray(A)

ans =

  logical

   0

>> isgpuarray(B)

ans =

  logical

   1
```
This confirms that array A is not on the GPU, but array B is.

##### Retrieve Array from GPU
To retrieve an array from the GPU and put it back in the MATLAB workspace, use the `gather` function.
It will copy the contents of an array on the GPU into a normal array.
This is necessary if you want to perform non-GPU actions on your data after using the GPU.
```bash
>> C = gather(B)
```
Now, we can test to see if C is stored on the GPU:
```bash
>> isgpuarray(C)

ans =

  logical

   0
```

#### Use functions on GPU Arrays
To perform functions on `gpuArray` objects, use the `arrayfun` function.
In this example, we will apply the MATLAB `sqrt` function to the array (B) that we created in the previous step:
```bash
result = arrayfun(@sqrt,B)
```
This will apply the `sqrt` function to every element in the GPU array.
`result` is also a GPU array:
```bash
>> isgpuarray(result)

ans =

  logical

   1

```

To see a list of MATLAB functions that are supported using GPUs, visit [https://www.mathworks.com/help/parallel-computing/gpuarray.html](https://www.mathworks.com/help/parallel-computing/gpuarray.html)

You can also create your own functions to pass into `arrayfun`.

### Schedule a job
It is a good idea to do everything using a batch script and avoid the mistakes associated with interactive computing.
To get an idea of why performing functions on `gpuArray` objects is a good idea, let's create a simple MATLAB script that displays the amount of time it takes to perform the same computation on a CPU and on a GPU.
We will then create a Slurm script that schedules a job with a GPU to run the MATLAB script for us.

#### MATLAB Script
We will perform the `sqrt` function on a 5000x5000 array.
The use of `tic` and `toc` allows us to time the separate applications of `sqrt`.

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

#### Slurm Script

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
#SBATCH --ntasks 1
#SBATCH -G 1

cd <DIR>

module load matlab
matlab -nodisplay -r gpu_matlab > gpu_matlab.out
```

#### Submit Job to Queue

Now we can submit the job to the scheduler from the Easley head node:

```bash
easley:~$ sbatch gpu_matlab.sh
```

View the results:
```bash
easley:~$ cat gpu_matlab.out
```

## Using Multiple GPUs on a single Easley node

Easley contains some nodes with multiple GPUs.
MATLAB allows for the utilization of multiple GPUs on a single node in the same way you use multiple CPUs.
To show how this works, below is an example MATLAB script that will create a logistic map using all available GPUs on the assigned node.

The `parpool` object is used to create workers to parallelize the execution.
Each worker will grab its own GPU when performing actions with `gpuArray` objects.
For this to work properly, ensure that you have been allocated an equal number of CPUs as GPUs on the machine.
An example Slurm script is included below to give an idea of how to ask for the proper resources to be allocated.

### MATLAB Script

Create the following MATLAB script called `gpu_logistic_map.m`.
This simple MATLAB script creates a logistic map by iterating the logistic equation on a set of random populations.
A worker is created for each available GPU.
They will then split up the work performed in the `parfor` loop.
The result is a logistic map figure saved as `logistic_map.jpg`.
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

### Slurm Script

When using a multi-GPU partition on Easley, you must also set `--cpus-per-task` and `-G` to match the number of GPUs you are requesting, so that MATLAB can correctly find and utilize the available GPUs.
These numbers should match, as MATLAB will use a CPU to access each GPU.
In the example below, we ask for two CPUs and two GPUs.

Create the following Slurm script called `gpu_logistic_map.sh`.
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
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH -G 2

cd <DIR>

module load matlab
matlab -nodisplay -r gpu_logistic_map > gpu_logistic_map.out
```

### Submit Job to Queue

Now we can submit the job to the scheduler from the Easley head node:
```bash
easley:~$ sbatch gpu_logistic_map.sh
```
View the results:
```bash
easley:~$ cat gpu_logistic_map.out
```

You can also view the `logistic_map.jpg` image using your preferred method.

*This QuickByte was validated on 6/23/2026.*
