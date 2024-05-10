## Parallel MATLAB Server
MATLAB supports parallelization on desktop computers which can be used to increase the speed of analysis drastically. MATLAB also provides the MATLAB Parallel Server (previously the MATLAB Distributed Computing Server) which allows you to write MATLAB code on your local desktop or laptop computer and perform the computation using the CARC high-performance clusters. This QuickByte leads you through the steps needed to set this up. If you run into problems please send an email to help@carc.unm.edu and we will be happy to help.

Please ensure you have the MATLAB Parallel Toolbox installed on your local comnputer.

## How MATLAB Parallel Works Behind the Scenes
MATLAB parallel allows the MATLAB session you interact with on your local computer, also known as the MATLAB client, with the PBS scheduler at CARC to create jobs that run on a core, also known as the MATLAB worker. The PBS (Portable BAtch system) scheduler allocates resources requested to users. One of the advantages of using MATLAB at CARC is the ability to scale up, or use many nodes for data intensive and/or computationally complex computations. To do this, you will request more workers from the PBS scheduler by following the tutorial bellow (Workers window). If you request multiple workers, it is important to keep in mind that one worker will be running the batch script you have sent from your MATLAB client. This worker is sending your scripts to the other workers that will perform your computations. You can think about this lead MATLAB worker as a mirror of your MATLAB client that communicates with the PBS scheduler and your scripts to accomplish your job. For more help on how to alter your scripts to take advantage of the scaleing up abilities at CARC please visit the Mathworks [tutorials](https://www.mathworks.com/help/parallel-computing/what-is-parallel-computing.html).


### MATLAB Parallel Server Client Configuration

Once MATLAB is installed on your local machine (the MATLAB version on your local machine must match the version on the CARC cluster) click "add-ons" to open Add-on explorer. Search for PBS. 

Click on the link "Parallel Computing Toolbox plugin for MATLAB Parallel Server with PBS" (there is a plugin for slurm as well).

Click the "install" button and the plugin will install and a wizard is started.

![Install](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabInstall.png)

![Wizard1](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabWizard1.png)
Choose UNIX in the cluster type

![Wizard2](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabWizard2.png)

Select no for shared job location.

![Wizard3](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabWizard3.png)

Enter the address of the cluster you would like to use: for example, wheeler.alliance.unm.edu or xena.alliance.unm.edu.

Enter </users/> for the path to the PBS scripts (remote job storage location) that MATLAB will create on the cluster.

Select unique subfolders.
  
![Wizard4](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabWizard4.png)

Select the number of workers and number of threads per worker. This may depend on the program you are running but in general you should have one worker per core on the cluster. For set up and validation leave the number of workers at 1. Leave the threads per worker at 1 unless your software requires more threads.

Specify the path to the matlab installation on the compute nodes: /opt/local/MATLAB/R2019a (or 2020a) for the Xena cluster, and /opt/local/MATLAB/R2019a for the Wheeler cluster. It is important that you are running the same version of MATLAB as you are 
running on the wheeler cluster. 

![Wizard6](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabWizard6.png)

Choose flexnet for the license

![Wizard7](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabWizard7.png)

Name your profile. For example "R2019a_Wheeler_PBS"

![Wizard8](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabWizard8.png)

Review your profile settings and create the profile.

![Wizard10](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabWizard10.png)

You can create multiple profiles for different CARC clusters and numbers of workers.

parallel.cluster.generic.runProfileWizard()

## Setting your IP Address

In the next steps MATLAB will need to know your local IP address to allow incoming/outgoing connections on your computer.

You will likely have to tell the system the IP address or hostname of your local machine. This is so the CARC cluster can communicate with your laptop or desktop. You will set the hostname with pctconfig (Parallel Config Toolbox). You can either type the hostname in directly or attempt to have MATLAB find it for you with the following commands:

OS X
```
[~,name]=system('ipconfig getifaddr en0');
pctconfig('hostname',name);
```

Linux
```
%%
[~,name]=system('hostname -i');
pctconfig('hostname',name);
```

Windows 10

Look up your computers IP address and enter:

```
%%
pctconfig('hostname',"<your IP address>");
```


### Validating the Configuration

Select "parallel" then create/manage clusters. 

Choose the profile you just created. In this example, the profile name is "R2019a_Wheeler_PBS"

![Validating1](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabValidate1.png)

Select the profile you just created and select the validation tab. Press the validate button.

![Validating2](https://github.com/UNM-CARC/QuickBytes/blob/master/ParallelMatlabValidate2.png)

It will ask for your CARC username, and here you can also select your ssh keyfile if you use one (cmd+shift+. to reveal hidden directories so you can see you ~/.ssh folder and select your private key), or just enter your password.

MATLAB will now validate your setup. If you run into trouble please contact CARC support at help@carc.unm.edu.

This completes the install and configuration.

We have found it best to restart MATLAB at this point, otherwise setting the hostname in the next step may not work.

### Writing Parallel Matlab Code


Once you have set the hostname you can run your parallel MATLAB code. Mathworks provides extensive documentation on using parallelism in MATLAB: [Mathworks Docs](https://www.mathworks.com/help/parallel-computing/getting-started-with-parallel-computing-toolbox.html)

The very simple program that follows demonstrates how to run parallel code using MATLAB. The code uses parfor, which can often be used to replace a for loop in serial MATLAB code, to distibute the work across 10 parallel workers.

```
n_workers = 10;                  % We will request 10 workers to run in parallel
p = parpool('R2019a_Wheeler_PBS', n_workers); % Create the pool of workers using the profile created earlier with 10 workers.
parfor i = 1:100                % Define a parallel loop that will be distributed accross the 10 workers.
i                               % Print the value of i for this iteration.
end                   
delete(p);                      % Clean up the worker pool
```

## Monitoring MATLAB Jobs
To check that your jobs are indeed running at CARC, you can log in (ssh) to the cluster you have submitted your job to and check your job status. The command bellow shows only your jobs. 

```
ssh username@wheeler.alliance.unm.edu 

qstat -u <username>
```

If you are testing small scripts, they may run before you can type qstat. To watch your jobs, you can type watch before the qstat (or anyother) command and it will re-run the command every 2sec. This is a good way to watch progress. 
