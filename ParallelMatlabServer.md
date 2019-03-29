## Parallel MATLAB Server
MATLAB supports parallelization on desktop computers which can be used to increase the speed of analysis drastically. MATLAB also provides the MATLAB Parallel Server (previously the MATLAB Distributed Computing Server). 

Once MATLAB is installed on your local machine (the NATLAB version on your local machine must match the version on the CARC cluster).

Click "add-ons" to open Add-on explorer. Search for PBS. 

Click on the link "Parallel Computing Toolbox plugin for MATLAB Parallel Server with PBS" (there is a plugin for slurm as well).

Click the "install" button and the plugin will install and a wizard is started.

Screenshot 1

Choose UNIX in the cluster type

Screenshot 2

Select no for shared job location.

Screenshot 3

Enter the address of the cluster you would like to use: for example, wheeler.alliance.unm.edu.

Enter /users/<your username> for the path to the PBS scripts that MATLAB will create on the cluster. Choosing will work.

Screenshot 4

Select unique subfolders.

Select the number of workers and number of threads per worker. This may depend on the program you are running but in general you should have one worker per core on the cluster. Leave the threads per worker at 1 unless your software requires more threads.

Screenshot 5

Specify the path to the matlab installation on the compute nodes: /opt/matlab/R2018b

Screenshot 6

Choose flexnet for the license

Screenshot 7

Name your profile. For example "Xena_workers32"

Screenshot 8

Review your profile settings and create the profile.

Screenshot 9 

You can create multiple profiles for different CARC clusters and numbers of workers.

Select "parallel" then create/manage clusters.

Select the profile you just created and select validate.

It will ask for your CARC username, and here you can also select your ssh keyfile if you use one (cmd+shift+. to reveal hidden directories so you can see you ~/.ssh folder and select your private key), or just enter your password.

MATLAB will now validate your setup. If you run into trouble please contact CARC support at help@carc.unm.edu

Now we will have to set the hostname of your local machine with pctconfig (Parallel Config Toolbox):

```
%% set hostname for a Mac
[~,name]=system('ipconfig getifaddr en0');
pctconfig('hostname',name);

%% set hostname for a linux machine
[~,name]=system('hostname -i');
pctconfig('hostname',name);

%% set hostname for a Windows machine
% need to add this
```

This completes the install and configuration.

The sample program that follows demonstrates how to run parallel code using MATLAB.

