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

It is highly reccommended to use the dualGPU partition and request two GPUs.
The commands below will show you how to use both the single and dual GPU partitions.

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

Use the file brower on the left side of the window to move into your 'deepLearningExample' directory within MATLAB.

### Get Required Example Functions

Before continuing, you must move the given MathWorks MATLAB functions (.m files) into yourly created 'deepLearningExample` directory. 
There are two ways to locate these files.

1. Locate them interactively in MATLAB GUI.
2. Locate them using the terminal. 

#### Locate them interactively in MATLAB GUI

Follow these steps to locate the files from with the MATLAB GUI opened in the above step.

1. Attempt to use an example function with blank arguments in the MATLAB Command Window.
```bash
>> downloadIAPRTC12Data('','')
```
2. That will cause an error and provide links to the examples MATLAB thinks you are using. Click on the `JPEG Image Deblocking Using Deep Learning` link.
3. This will move MATLAB's current wortking directory to that of the Example code.
4. In the file browser on the left side of the window, select all of the files in the current directory.
5. Right click the selected files and hit 'copy'.
6. Use the file brower on the left side to navigate back to your 'deepLearningExample' directory.
7. Right click in the file brower and select paste to place all the files in this directory.

#### Locate them using the terminal

Follow these steps to copy the required example code into your new directory.

1. Ssh into the compute node assigned to you (make sure the MATLAB module is loaded).
```bash
xena:~$ ssh xena-01
```
2. Move into the MATLAB Examples directory.
```bash
xena-01:~$ cd /tmp/Examples/R2021a/deeplearning_shared/JPEGImageDeblockingDeepLearningExample
```
3. Copy all the needed files.
```bash
xena-01:~$ cp *.m ~/deepLearningExample
```
4. (Optional) Copy the pretrained example CNN.
```bash
xena-01:~$ cp pretrianedJPEGDnCNN.mat ~/deepLearningExample
```


### Create MATLAB script
Now, create the following MATLAB script with the name 'deep_learning_example.m' and ensure it lives within the directory created above ('~/deepLearningExample/').
```bash
dataDir = '~/deepLearningExample/data';

% Ensure the data is downloaded first
isDownloaded = false;
if ~isDownloaded
    downloadIAPRTC12Data('http://www-i6.informatik.rwth-aachen.de/imageclef/resources/iaprtc12.tgz',dataDir);
end

% Grab Subset of data for training
trainImagesDir = fullfile(dataDir, "iaprtc12","images","00");
exts = [".jpg",".bmp",".png"];
imdsPristine = imageDatastore(trainImagesDir,FileExtensions=exts);

% Prepare Training Data by compressing at various levels of quality

JPEGQuality = [5:5:40 50 60 70 80];

isCompressed = false;

if ~isCompressed
    [compressedDirName,residualDirName] = createJPEGDeblockingTrainingSet(imdsPristine,JPEGQuality);
else
    compressedDirName = fullfile(dataDir,"iaprtc12","images","00","compressedImages");
    residualDirName = fullfile(dataDir,"iaprtc12","images","00","residualImages");
end

% Create Random Patch Extraction Datastore for Training

imdsCompressed = imageDatastore(compressedDirName,FileExtensions=".mat",ReadFcn=@matRead);
imdsResidual = imageDatastore(residualDirName,FileExtensions=".mat",ReadFcn=@matRead);

augmenter = imageDataAugmenter(...
    RandRotation=@()randi([0,1],1)*90,...
    RandXReflection=true);


patchSize = 50;
patchesPerImage = 128;

% Prepare dataset and setup CNN options

dsTrain = randomPatchExtractionDatastore(imdsCompressed,imdsResidual,patchSize, ...
    PatchesPerImage=patchesPerImage, ...
    DataAugmentation=augmenter);
dsTrain.MiniBatchSize = patchesPerImage;

inputBatch = preview(dsTrain);
disp(inputBatch)

layers = dnCNNLayers

maxEpochs = 10;
initLearningRate = 0.1;
l2reg = 0.0001;
batchSize = 64;

options = trainingOptions("sgdm", ...
    Momentum=0.9, ...
    InitialLearnRate=initLearningRate, ...
    LearnRateSchedule="piecewise", ...
    GradientThresholdMethod="absolute-value", ...
    GradientThreshold=0.005, ...
    L2Regularization=l2reg, ...
    MiniBatchSize=batchSize, ...
    MaxEpochs=maxEpochs, ...
    Plots="training-progress", ...
    ExecutionEnvironment='multi-gpu',...
    Verbose=true);

% Train the network

doTraining = true;

if doTraining
    [net,info] = trainNetwork(dsTrain,layers,options);
    modelDateTime = string(datetime("now",Format="yyyy-MM-dd-HH-mm-ss"));
    save("trainedJPEGDnCNN-"+modelDateTime+".mat","net");
end

return
```
If you are using a single GPU machine, change this line:
```bash
ExecutionEnvironment='multi-gpu'
```
into this:
```bash
ExecutionEnvironment='gpu'
```


#### Sbsequent uses of this Script

The script uses the following booleans to allow you to skip various steps.

Once you have downloaded the data, change this line:
```bash
isDownloaded = false;
```
to this:
```bash
isDownloaded = true;
```

Once you have compressed the data, change this line:
```bash
isCompressed = false;
```
to this:
```bash
isCompressed = true;
```

### Train Interactively

To train the network interactively, run the script from within the interactive MATLAB session's Command Window
```bash
>> deep_learning_example
```

Once the data is downloaded and compressed, a window will pop up to track the training progress.

Downloading and compressing the images can take quite a few minutes.
Training the model takes up to 9 hours to complete 10 epochs on the dual GPU machines.
Due to the way MATLAB trains a network with this depth (20 convolutional layers by default), these machines run out memory when training the network past 12 epochs with the rest of the settings left unchanged.
One way to reduce memory usage and training time is top use fewer compressed images in the training set.
Another option is to use a different layer setup with fewer hidden layers.

## Train CNN via Scheduled Job

Since training this CNN can take many hours, it is a good idea to take advantage of the Slurm scheduler.
Interactive jobs can be stopped and interrupted due to internet connection issues.
In the options of the CNN itself we set `Verbose=true`, which will allow us to see the status of the model being trained in an ouput file that is updated in real time.


### Slurm Scripts

It is reccomended that you use the dual GPU machines.
When using either of the scripts below, ensure the `ExecutionEnvironment` option in the above MATLAB script matches your choice of machine.

#### Single GPU

#### Dual GPU

### View Results

While a network is being trained, you can see the results in real time with the `cat` command.

If you used the single GPU slurm script, use this command to view the output:
```bash
xena:~$ cat deepLearningExamples/SOMETHING.out
```

If you used the dual GPU slurm script, use this command to view the output:
```bash
xena:~$ cat deepLearningExamples/SOMETHING_ELSE.out
```

## Test the Model


