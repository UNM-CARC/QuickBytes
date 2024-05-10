#  MATLAB Deep Learning on Xena

MATLAB has great tools for deep learning and convolutional neural networks (CNNs).
These tools can make use of GPUs, which are available for use on the Xena cluster.
This Quickbytes tutorial will mimic the official Mathworks tutorial on using deep learning for JPEG Image Deblocking.
To see that tutorial, follow this [link.](https://www.mathworks.com/help/images/jpeg-image-deblocking-using-deep-learning.html#JPEGImageDeblockingUsingDeepLearningExample-2 "MathWorks Deep Learning Tutorial")

Before we begin, create a directory named 'deepLearningExample' from within your home directory.
```bash
xena:~$ cd ~
xena:~$ mkdir deepLearningExample
```

## Table of Contents

1. [Train CNN Interactively](#1)
    1. [Open MATLAB](#1.1)
    2. [Get Required Example Functions](#1.2)
        1. [Locate them interactively in MATLAB GUI](#1.2.1)
        2. [Locate them using the terminal](#1.2.2)
    3. [Create MATLAB script](#1.3)
        1. [Subsequent uses of this Script](#1.3.1)
    4. [Train Interactively](#1.4)
2. [Train CNN via Scheduled Job](#2)
    1. [Slurm Scripts](#2.1)
        1. [Single GPU](#2.1.1)
        2. [Dual GPU](#2.1.2)
    2. [Submit Script](#2.2)
    3. [View Results](#2.3)
3. [Test Model](#3)
    1. [MATLAB Script](#3.1)
    2. [Changes you can make to the test_model.m script](#3.2)
        1. [Different test image](#3.2.1)
        2. [Zoom in on specific ROI](#3.2.2)


## Train CNN Interactively <a name="1"></a>
It is possible to train the the example CNN in an interactive MATLAB session and track the progress.
This requires X11 fowarding.
For a full guide on how to do that, please view our [Quickbytes youtube tutorial.](https://www.youtube.com/watch?v=-5ic9JWHuqI&t=224s&ab_channel=UNMCARC "Quickbytes X11 Forwarding Tutorial").
Please note that you should not fully train a CNN interactively as the plotting requires large amounts of memory.
It is alright to use the interactive plotting to verify that a model is training.
In order to fully train a model, please schedule a job using a slurm script and disable the plotting.

### Open MATLAB <a name="1.1"></a>

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

### Get Required Example Functions <a name="1.2"></a>

Before continuing, you must move the given MathWorks MATLAB functions (.m files) into yourly created 'deepLearningExample` directory. 
There are two ways to locate these files.

1. Locate them interactively in MATLAB GUI.
2. Locate them using the terminal. 

#### Locate them interactively in MATLAB GUI <a name="1.2.1"></a>

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

#### Locate them using the terminal <a name="1.2.2"></a>

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


### Create MATLAB script <a name="1.3"></a>
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
    % WARNING - turning on plots uses massive amounts of RAM. Do not run for more than 3 or 4 epochs.
    %Plots="training-progress", ...
    Plots="none", ...
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


#### Subsequent uses of this Script <a name="1.3.1"></a>

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

### Train Interactively <a name="1.4"></a>

To train the network interactively, run the script from within the interactive MATLAB session's Command Window
```bash
>> deep_learning_example
```

In the MATLAB script, you can change the 'Plotting' option to view a plot of the training status in real time.
However, this uses massive amounts of RAM and should not be run for more than 3 or 4 epochs.
You can use the plotting as verification that a model is actually training, but you should not attempt to fully train a model with the plotting enabled.

Downloading and compressing the images can take quite a few minutes.
Training the model takes up to 9 hours to complete 10 epochs on the dual GPU machines.
Due to the way MATLAB trains a network with this depth (20 convolutional layers by default), these machines run out memory when training the network past 12 epochs with the rest of the settings left unchanged.
One way to reduce memory usage and training time is top use fewer compressed images in the training set.
Another option is to use a different layer setup with fewer hidden layers.

## Train CNN via Scheduled Job <a name="2"></a>

Since training this CNN can take many hours, it is a good idea to take advantage of the Slurm scheduler.
Interactive jobs can be stopped and interrupted due to internet connection issues.
In the options of the CNN itself we set `Verbose=true`, which will allow us to see the status of the model being trained in an ouput file that is updated in real time.


### Slurm Scripts <a name="2.1"></a>

It is reccomended that you use the dual GPU machines.
When using either of the scripts below, ensure the `ExecutionEnvironment` option in the above MATLAB script matches your choice of machine.

#### Single GPU <a name="2.1.1"></a>

To request a job with a single GPU, create the following script with the name 'dncnn_single_gpu.sh':

```bash
#!/bin/bash

#SBATCH --job-name DnCNN_singleGPU
#SBATCH --mail-user jmccullough12@unm.edu
#SBATCH --mail-type ALL
#SBATCH --output dncnn_single_gpu.out
#SBATCH --error dncnn_single_gpu.err
#SBATCH --time 48:00:00
#SBATCH --partition singleGPU
#SBATCH --ntasks 1
#SBATCH --mem 0
#SBATCH --cpus-per-task 16
#SBATCH -G 1

cd ~/deepLearningExample

module load matlab
matlab -nodisplay -r deep_learning_example > dncnn_single_training.out

```

#### Dual GPU <a name="2.1.2"></a>

To request a job with dual GPUs, create the following script with the name 'dncnn_dual_gpu.sh':

```bash
#!/bin/bash

#SBATCH --job-name DnCNN_DualGPU
#SBATCH --mail-user <YOUR EMAIL>
#SBATCH --mail-type ALL
#SBATCH --output dncnn_dual_gpu.out
#SBATCH --error dncnn_dual_gpu.err
#SBATCH --time 48:00:00
#SBATCH --partition dualGPU
#SBATCH --ntasks 1
#SBATCH --mem 0
#SBATCH --cpus-per-task 16
#SBATCH -G 2

cd ~/deepLearningExample

module load matlab
matlab -nodisplay -r deep_learning_example > dncnn_dual_training.out
```

### Submit Script <a name="2.2"></a>

To submit a job request using the single GPU script, use the following command:
```bash
xena:~$ sbatch dncnn_single_gpu.sh
```

To submit a job request using the dual GPU script, use the following command:
```bash
xena:~$ sbatch dncnn_dual_gpu.sh
```

### View Results <a name="2.3"></a>

While a network is being trained, you can see the results in real time with the `cat` command.

If you used the single GPU slurm script, use this command to view the output:
```bash
xena:~$ cat ~/deepLearningExamples/dncnn_single_training.out
```

If you used the dual GPU slurm script, use this command to view the output:
```bash
xena:~$ cat ~/deepLearningExamples/dncnn_dual_training.out
```

## Test the Model <a name="3"></a>

Once a model has finished training, it will be saved to a .mat file with a name like: `trainedJPEGDnCNNyyyy-MM-dd-HH-mm-ss.mat`
You can also use the pretrained example model (see the above instructions to get the example MATALB function files).

### MATLAB Script <a name="3.1"></a>

Use the following MATLAB Script to the results of a trianed model.
To specify which model to use, replace the `<MODEL FILE>` with the name of your model.

If the script is run interactively with X11 fowarding (see above instructions), an image will appear that shows the predictions made on a test image,.
The resulting comparisons are also saved to an imaged titled 'results.tif' which can be viewed with your preferred image viewer.

Create the following script with the name 'test_model.m' and ensure it lives in the 'deepLearningExample' directory.
```bash
% Open and test results of trained CNN model for JPEG Denoising

% Load the model from file

load("trainedJPEGDnCNN-2022-05-23-00-37-23.mat");

% Open test images

fileNames = ["sherlock.jpg","peacock.jpg","fabric.png","greens.jpg", ...
    "hands1.jpg","kobi.png","lighthouse.png","office_4.jpg", ...
    "onion.png","pears.png","yellowlily.jpg","indiancorn.jpg", ...
    "flamingos.jpg","sevilla.jpg","llama.jpg","parkavenue.jpg", ...
    "strawberries.jpg","trailer.jpg","wagon.jpg","football.jpg"];
filePath = fullfile(matlabroot,"toolbox","images","imdata")+filesep;
filePathNames = strcat(filePath,fileNames);
testImages = imageDatastore(filePathNames);


% Select an image to view - choose an image name from the above list.

testImage = "lighthouse.png";
Ireference = imread(testImage);

% Compress the test image in three different levels of quality

imwrite(Ireference,fullfile(tempdir,"testQuality10.jpg"),"Quality",10);
imwrite(Ireference,fullfile(tempdir,"testQuality20.jpg"),"Quality",20);
imwrite(Ireference,fullfile(tempdir,"testQuality50.jpg"),"Quality",50);

I10 = imread(fullfile(tempdir,"testQuality10.jpg"));
I20 = imread(fullfile(tempdir,"testQuality20.jpg"));
I50 = imread(fullfile(tempdir,"testQuality50.jpg"));

I10ycbcr = rgb2ycbcr(I10);
I20ycbcr = rgb2ycbcr(I20);
I50ycbcr = rgb2ycbcr(I50);

% Apply network to compressed test images

I10y_predicted = denoiseImage(I10ycbcr(:,:,1),net);
I20y_predicted = denoiseImage(I20ycbcr(:,:,1),net);
I50y_predicted = denoiseImage(I50ycbcr(:,:,1),net);

I10ycbcr_predicted = cat(3,I10y_predicted,I10ycbcr(:,:,2:3));
I20ycbcr_predicted = cat(3,I20y_predicted,I20ycbcr(:,:,2:3));
I50ycbcr_predicted = cat(3,I50y_predicted,I50ycbcr(:,:,2:3));

I10_predicted = ycbcr2rgb(I10ycbcr_predicted);
I20_predicted = ycbcr2rgb(I20ycbcr_predicted);
I50_predicted = ycbcr2rgb(I50ycbcr_predicted);

% View and save results

montage({I50,I20,I10,I50_predicted,I20_predicted,I10_predicted},Size=[2 3])
title("Compressed Images (above) Compared to Deblocked Images (below) with Quality Factor 50, 20 and 10 (Left to Right)")

imwrite(getframe(gca).cdata,'results.tif','tif');

% Change the following boolean to look closer at a specific region of
% interes in the test image

doROI = false;

if doROI
    roi = [30 440 100 80];
    i10 = imcrop(I10,roi);
    i20 = imcrop(I20,roi);
    i50 = imcrop(I50,roi);
    i10predicted = imcrop(I10_predicted,roi);
    i20predicted = imcrop(I20_predicted,roi);
    i50predicted = imcrop(I50_predicted,roi);
    montage({i50,i20,i10,i50predicted,i20predicted,i10predicted},Size=[2 3])
    title("Compressed Images ROI (above) Compared to Deblocked Images ROI (below) with Quality Factor 50, 20 and 10 (Left to Right)")
    imwrite(getframe(gca).cdata,'results_roi.tif','tif');
end


```
### Changes you can make to the test_model.m script <a name="3.2"></a>

The above script can be modified for two different kinds of functionality:

1. Use a different test image
2. Zoom in on a specific region of interest (ROI)

#### Different test image <a name="3.2.1"></a>
You can change the test image by changing the line: 
```bash
testImage = "lighthouse.png";
```
to any of the images in the list of filenames, directly above in the script.

#### Zoom in on specific ROI <a name="3.2.2"></a>
To zoom in on a specific region of interest, change the following line:
```bash
doROI = false;
```
to
```bash
doROI = true;
```

Then ROI can be changed by modifying this line:
```bash
roi = [30 440 100 80];
```

This region works well when using `lighthouse.png` as your test image.

Running the script with the boolean changed will display and save a image of the results zoomed in on the ROI.
If you are using X11 forwarding, the image should appear on your display.
The results are also saved to an image ('results_roi.tif') that can be viewed in your choice of image viewer.
