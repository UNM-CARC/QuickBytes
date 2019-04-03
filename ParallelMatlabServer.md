## Parallel MATLAB Server
MATLAB supports parallelization on desktop computers which can be used to increase the speed of analysis drastically. MATLAB also provides the MATLAB Parallel Server (previously the MATLAB Distributed Computing Server) which allows you to write MATLAB code on your local desktop or laptop computer and perform the computation using the CARC high-performance clusters. This QuickByte leads you through the steps needed to set this up. If you run into problems please send an email to help@carc.unm.edu and we will be happy to help.

Please ensure you have the MATLAB Parallel Toolbox installed on your local comnputer.

### MATLAB Parallel Server Client Configuration

Once MATLAB is installed on your local machine (the MATLAB version on your local machine must match the version on the CARC cluster) click "add-ons" to open Add-on explorer. Search for PBS. 

Click on the link "Parallel Computing Toolbox plugin for MATLAB Parallel Server with PBS" (there is a plugin for slurm as well).

Click the "install" button and the plugin will install and a wizard is started.

![Install](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabInstall.png)

![Wizard1](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabWizard1.png)
Choose UNIX in the cluster type

![Wizard2](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabWizard2.png)

Select no for shared job location.

![Wizard3](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabWizard3.png)

Enter the address of the cluster you would like to use: for example, wheeler.alliance.unm.edu or xena.alliance.unm.edu.

Enter /users/<your username> for the path to the PBS scripts (remote job storage location) that MATLAB will create on the cluster.

Select unique subfolders.
  
![Wizard4](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabWizard4.png)

Select the number of workers and number of threads per worker. This may depend on the program you are running but in general you should have one worker per core on the cluster. Leave the threads per worker at 1 unless your software requires more threads.

Specify the path to the matlab installation on the compute nodes: /opt/matlab/R2018b

![Wizard6](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabWizard6.png)

Choose flexnet for the license

![Wizard7](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabWizard7.png)

Name your profile. For example "xena-distributed"

![Wizard8](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabWizard8.png)

Review your profile settings and create the profile.

![Wizard10](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabWizard10.png)

You can create multiple profiles for different CARC clusters and numbers of workers.

### Validating the Configuration

Select "parallel" then create/manage clusters.

![Validating1](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabValidate1.png)

Select the profile you just created and select validate.

![Validating2](https://github.com/UNM-CARC/QuickBytes/blob/parallel_matlab_server/ParallelMatlabValidate2.png)

It will ask for your CARC username, and here you can also select your ssh keyfile if you use one (cmd+shift+. to reveal hidden directories so you can see you ~/.ssh folder and select your private key), or just enter your password.

MATLAB will now validate your setup. If you run into trouble please contact CARC support at help@carc.unm.edu.

This completes the install and configuration.

### Writing Parallel Matlab Code

You will likely have to tell the system the IP address or hostname of your local machine. This is so the CARC cluster can communicate with your laptop or desktop. You will set the hostname with pctconfig (Parallel Config Toolbox). You can either type the hostname in directly or attempt to have MATLAB find it for you with the following commands:

```
%% set hostname for a Mac
[~,name]=system('ipconfig getifaddr en0');
pctconfig('hostname',name);
```

```
%% set hostname for a linux machine
[~,name]=system('hostname -i');
pctconfig('hostname',name);
```

Once you have set the hostname you can run your parallel MATLAB code. Mathworks provides extensive documentation on using parallelism in MATLAB: [Mathworks Docs](https://www.mathworks.com/help/parallel-computing/getting-started-with-parallel-computing-toolbox.html)

The very simple program that follows demonstrates how to run parallel code using MATLAB. The code uses parfor, which can often be used to replace a for loop in serial MATLAB code, to distibute the work across 10 parallel workers.

```
n_worker = 10;                  % We will request 10 workers to run in parallel
p = parpool('xena-distributed', n_workers); % Create the pool of workers using the profile created earlier with 10 workers.
parfor i = 1:100                % Define a parallel loop that will be distributed accross the 10 workers.
i                               % Print the value of i for this iteration.
end                   
delete(p);                      % Clean up the worker pool
```
