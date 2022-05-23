#  MATLAB Deep Learning on Xena
MATLAB has great tools for deep learning and convolutional neural networks (CNNs).
These tools can make use of GPUs, which are available for use on the Xena cluster.
This Quickbytes tutorial will mimic the official Mathworks tutorial on using deep learning for JPEG Image Deblocking.
To see that tutorial, follow this [link.](https://www.mathworks.com/help/images/jpeg-image-deblocking-using-deep-learning.html#JPEGImageDeblockingUsingDeepLearningExample-2 "MathWorks Deep Learning Tutorial")

Before we begin, create a directory named 'deepLearningExample' from within your home directory
```bash
xena:~$ cd ~
xena:~$ mkdir deepLearningExample
```

## Train CNN Interactively
It is possible to train the the example CNN in an interactive MATLAB session and track the progress.
This requires X11 fowarding.
For a full guide on how to do that, please view our [Quickbytes youtube tutorial.](https://www.youtube.com/watch?v=-5ic9JWHuqI&t=224s&ab_channel=UNMCARC "Quickbytes X11 Forwarding Tutorial")  

### Open MATLAB

Once logged into Xena with X11 fowarding, you can begin an interactive job on a compute node.
```bash
xena:~$ srun --partition singleGPU --x11 --mem 0 --ntasks 1 --cpus-per-task 16 -G 1 --pty bash
```

This requests a single node and gpu with X11 forwarding.

To use a machine with two gpus, use this command instead:
```bash
xena:~$ srun --partition dualGPU --x11 --mem 0 --ntasks 1 --cpus-per-task 16 -G 2 --pty bash
```

Once you are assigned a compute node, cd into our new directory, then start an interactive session of MATLAB:
```bash
xena-01:~$ cd deepLearningExample/
xena-01:~$ module load matlab
xena-01:~$ matlab
```

This should bring up the MATLAB graphical user interface (GUI).

### Create MATLAB script
Now, we
```bash
>> dataDir = '~/deepLearningExample/data/';
```
### Get Required Example Functions

### Train Interactively

## Train CNN via Scheduled Job

### Slurm Script

### View Results

## Test the Model


