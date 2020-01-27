# X11 Forwarding for Add-ons on MATLAB

X11 Forwarding allows the MATLAB graphical user interface to open on your client machine while MATLAB itself is being run on a 
CARC machine. This is necessary to select add-ons that may be necessary for your computations. This QuickByte will show you how 
to do this yourself. 


## On a Mac

Before getting started, make sure you have [XQuartz](https://www.xquartz.org) downloaded and installed. This allows the X11 
forwarding. 


## On a PC

Before getting started, download [MobaXterm](https://mobaxterm.mobatek.net) and install. This has a built in xserver, that will 
connect your computer to CARC. 


## Step by Step X11 forwarding with MATLAB

1. In terminal sign into the CARC system using secure system connection. However, use a -X flag to enable X11 forwarding. 

``` 
$ ssh -X username@wheeler.alliance.unm.edu
```

2. Start an interactive session using qsub, but again include the -X flag. 

```
$ qsub -IX -l nodes=1:ppn=1
```

3. Once you have been assiged a node, load the MATLAB module. Then start MATLAB. You should automatically get a MATLAB GUI 
poping us on your computer. 

``` 
$ module load matlab
$ matlab
```

4. Use the MATLAB GUI to load your add-on as you usually would. 

5. When you are finished loading your add-on, click the x to close the GUI. Lastly, exit the interactive session to release the 
node for other users. 


If you have any trouble at any point please reach out to us at help@carc.unm.edu 

