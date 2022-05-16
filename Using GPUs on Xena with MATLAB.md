# Using GPUs with MATLAB

## Using a single GPU on Xena

Introduction coming soon.

### Identify and Select GPU

```bash
xena:~$ srun -G 1 --pty bash
```

Once you have a node allocated to you, load the MATLAB module and start a MATLAB session:

```bash
xena01:~$ module load matlab
xena01:~$ matlab

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

To get information about the available gpus, use this function:
```bash
>> gpuDeviceTable
```
That will print something that looks like this on Xena:
```bash
ans =

  1x5 table

    Index        Name        ComputeCapability    DeviceAvailable    DeviceSelected
    _____    ____________    _________________    _______________    ______________

      1      "Tesla K40m"          "3.5"               true              false
```

Next, you must tell MATLAB which GPU to use (pass in the desired index from the above table):
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

      1      "Tesla K40m"          "3.5"               true              true

```

### Using Arrays on GPU

In order to utilize the gpu, data must be loaded into a `gpuArray` object.
For a full description of the `gpuArray` object, please visit the official MathWorks Documentation at [https://www.mathworks.com/help/parallel-computing/gpuarray.html](https://www.mathworks.com/help/parallel-computing/gpuarray.html)

#### Initialize Array
First, create a normal array using any method you like.
In this example we will use the `magic(8)` function to create a magic square matrix that is 8x8.
```bash
>> A = magic(8)
```
Next, pass that into a `gpuArray` object:
```bash
>> B = gpuArray(A)
```

#### Test if array is on GPU
The `isgpuarray` function tests if an array is on a gpu:
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
This confirms that array A is not on the gpu, but array B is.

#### Retrieve Array from GPU
In order to retrieve an array from the gpu and put it back in the MATLAB workspace, use the `gather` function:
```bash
>> C = gather(B)
```
Now, we can test to see if C is stored on the gpu:
```bash
>> isgpuarray(C)

ans =

  logical

   0
```

### Use functions on GPU Arrays
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

To see a list of MATLAB functions that are supported using gpus, visit [https://www.mathworks.com/help/parallel-computing/gpuarray.html](https://www.mathworks.com/help/parallel-computing/gpuarray.html)

You can also create your own functions to pass into `arrayfun`.

### Schedule a job
It is good idea to do everything using a batch script and avoid the mistakes associated with interactive computing.
To get an idea of why performing functions on `gpuArray` objects is a good idea, let's create a simple MATLAB script that displays the amount of time it takes to perform the same computation on a cpu and on a gpu.
We will then create a PBS script that schedules a job with a GPU to run the MATLAB script for us.


#### MATLAB script
We will perform the `sqrt` function on a 5000x5000 array.
The use of `tic` and `toc` allow us to time the seperate applications of `sqrt`.

Create the following script with the name `gpu_matlab.m`:

```bash 
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
#### PBS Script

Now, let's create a PBS script called `gpu_matlab.pbs`. 
Replace the `<DIR>` with the path to the directory containing the MATLAB script created above. 
This script will request the desired resrouces, load the MATLAB module, then run the script.
The output of the script will be sent to the file: `gpu_matlab.out`

```bash
#!/bin/bash

#PBS -N gpu_test
#PBS -l walltime=00:05:00
#PBS -l nodes=1:ppn=1:gpus=1
#PBS -j oe

cd <DIR>

module load matlab

matlab -nodisplay -r gpu_matlab > gpu_matlab.out

```


#### Submit job to queue

Now we can submit the job to the scheduler from the xena head node:
```bash
xena:~$ qsub gpu_matlab.pbs
```
View the results:
```bash
xena01:~$ cat gpu_matlab.out
```

## Using Multiple GPUs on a single Xena node

Coming Soon!

## Using Multiple Nodes with their own GPUs

Coming Soon!
