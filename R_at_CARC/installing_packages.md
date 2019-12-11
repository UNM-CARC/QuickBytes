# Installing R packages

## Installing interactively

This is the way that most of us are probably comfortable with installing packages with R since it is exactly the same way you install packages on your laptop. However, because the head node of CARC systems is a shared resource it is best practice to not compile binaries for R for an extended period of time because it can result in overhead on the head node. To avoid this we can request a compute node for interactive use, or even better, one of our debug nodes. The actual call to Torque, our job scheduler, will be explained in more depth later, but for now to request an interactive node type the following at the command prompt on Wheeler:

```
yourusername@wheeler-sn$ qsub -I -l walltime=01:00:00 -l nodes=1:ppn=8
qsub: waiting for job 201775.wheeler-sn.alliance.unm.edu to start
qsub: job 201775.wheeler-sn.alliance.unm.edu ready

Wheeler Portable Batch System Prologue
Job Id: 201775.wheeler-sn.alliance.unm.edu
Username: liphardt
Job 201775.wheeler-sn.alliance.unm.edu running on nodes:
wheeler272 

prologue running on host: wheeler272
```
Which will request a compute node and log you in once it is ready. Load a R software module with your preferred method and start a R session. If this is your first time installing a R package for one of the major versions you will be prompted to use a personal library.

```
R version 3.6.0 (2019-04-26) -- "Planting of a Tree"
Copyright (C) 2019 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.


> install.packages("ape", dependencies=T, repos="http://cran.r-project.org")
Warning in install.packages("ape", dependencies = T, repos = "http://cran.r-project.org",  :
  'lib = "/opt/spack/opt/spack/linux-centos7-x86_64/gcc-7.3.0/r-3.6.0-7akol5ts7ebhhvoqz2tf6ghmc32hng7g/rlib/R/library"' is not writable
Would you like to use a personal library instead? (yes/No/cancel) 
yes
Would you like to create a personal library
'~/R/x86_64-pc-linux-gnu-library/3.6'
to install packages into? (yes/No/cancel)
yes
```
Go ahead and say `yes` to both questions and install packages normally. You only need to specify a personal library the first time you use a new major version. 

## Installing packages using a script

Installing packages in a script is a little more complicated so it might be easier to just do it interactively. However, it is possible. 

If you haven't created a personal library yet either interactively or through a script you first need to do that. The following commands in an R script will take care of this for you:

```
# First create the directory, .libPaths() will not append your library list unless the directory exists. 
dir.create(Sys.getenv("R_LIBS_USER", recursive=T, mode="0777"))

#Now append your library path with your newly created local library
.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))

#The above steps are only necessary the first time you are installing packages. Remove or comment out if you have already created a persional library.

#Now install packages normally
> install.packages("ape", dependencies=T, lib=Sys.getenv("R_LIBS_USER"), repos="http://cran.r-project.org")
```

The first two lines are only necessary when you have not created a personal library for that major version of R yet, otherwise you just need to specify the repos you are downloading packages from and specify your personal library as the install location. You shouldn't need to specify the library since you have appended your library path, but it doesn't hurt to be explicit.
