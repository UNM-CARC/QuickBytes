# X11 Forwarding 

X11 Forwarding allows any graphical user interface to open on your client machine while the software itself is being run on a 
CARC cluster compute node. This QuickByte will show you how to do X11 forwarding yourself. 


## On a Mac

Before getting started, make sure you have [XQuartz](https://www.xquartz.org) downloaded and installed. This allows the X11 
forwarding. 


## On a PC

Before getting started, download [MobaXterm](https://mobaxterm.mobatek.net) and install. This has a built in xserver, that will connect your computer to CARC. 


## Step by Step Example of X11 forwarding with MATLAB

1. In terminal sign into the CARC system using secure system connection. However, use a -X flag to enable X11 forwarding. 

``` 
$ ssh -X username@wheeler.alliance.unm.edu
```

If you get the error "/usr/bin/xauth: file /users/user/.Xauthority does not exist", use the command:

```
touch ~/.Xauthority
```

Log out and back in, and then move on to the next step. 

2. Start an interactive session using slurm, and include the X11 flag. 

```
$ srun --x11 --pty bash
```

Note that the equivalent command using qsub would be as follows:

```
$ qsub -IX -l nodes=1:ppn=1
```

3. Once you have been assigned a node, load the MATLAB module. Then start MATLAB. You should automatically get a MATLAB GUI 
poping us on your computer. 

``` 
$ module load matlab
$ matlab
```

4. Use the MATLAB GUI to load your add-on as you usually would. 

5. When you are finished loading your add-on, click the x to close the GUI. Lastly, exit the interactive session to release the 
node for other users. 

6. One can find a CARC quickbyte video on x forwarding by accessing the link below:

```
https://www.youtube.com/watch?v=-5ic9JWHuqI&list=PLvr5gRBLi7VAzEB_t5aXOLHLfdIu2s1hZ&index=12
```

If you have any trouble at any point please reach out to us at help@carc.unm.edu 

