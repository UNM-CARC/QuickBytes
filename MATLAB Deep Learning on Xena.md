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

% Prepare Training Data

JPEGQuality = [5:5:40 50 60 70 80];

%compressedImagesDir = fullfile(dataDir,"iaprtc12","JPEGDeblockingData","compressedImages");
%residualImagesDir = fullfile(dataDir,"iaprtc12","JPEGDeblockingData","residualImages");

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
    ExecutionEnvironment='gpu',...
    Verbose=true);

doTraining = true;

if doTraining
    [net,info] = trainNetwork(dsTrain,layers,options);
    modelDateTime = string(datetime("now",Format="yyyy-MM-dd-HH-mm-ss"));
    save("trainedJPEGDnCNN-"+modelDateTime+".mat","net");
end

return
```


#### Sbsequent uses of this Script

Booleans

### Get Required Example Functions

The script created above requires the usage of functions provided by MathWorks.
A quick way to find these functions 

### Train Interactively

## Train CNN via Scheduled Job

### Slurm Script

### View Results

## Test the Model


