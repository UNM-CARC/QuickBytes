# Installing R packages

## Installing interactively

This is the way that most of us are probably comfortable with installing packages with R since it is exactly the same way you install packages on your laptop. However, because the head node of CARC systems is a shared resource it is best practice to not compile binaries for R for an extended period of time because it can result in overhead on the head node. To avoid this we can request a compute node for interactive use, or even better, one of our debug nodes. The actual call to Slurm, our job scheduler, will be explained in more depth later, but for now to request an interactive node type the following at the command prompt on Easley:

```
yourusername@easley-sn$ srun --partition debug --time 01:00:00 --ntasks 8 --pty bash
```
Which will request a compute node and log you in once it is ready. Load a R software module with your preferred method and start a R session. If this is your first time installing a R package for one of the major versions you will be prompted to use a personal library.

```
R version 4.5.2 (2025-10-31) -- "[Not] Part in a Rumble"
Copyright (C) 2025 The R Foundation for Statistical Computing
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


> install.packages("ape", dependencies=T, repos="https://cran.r-project.org")
Warning in install.packages("ape", dependencies = T, repos = "https://cran.r-project.org",  :
  'lib = "/opt/spack/opt/spack/linux-sapphirerapids/r-4.5.2-pspoemzrzcxde2luqrubfnbfq7higpsr/rlib/R/library"' is not writable
Would you like to use a personal library instead? (yes/No/cancel) 
yes
Would you like to create a personal library
'~/R/x86_64-pc-linux-gnu-library/4.5'
to install packages into? (yes/No/cancel)
yes
```

This is with `r/4.5.2-pspo` loaded. See the `libdeflate` known issue in `getting_R_software.md` if you hit a shared-library error before even getting this far.
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
> install.packages("ape", dependencies=T, lib=Sys.getenv("R_LIBS_USER"), repos="https://cran.r-project.org")
```

The first two lines are only necessary when you have not created a personal library for that major version of R yet, otherwise you just need to specify the repos you are downloading packages from and specify your personal library as the install location. You shouldn't need to specify the library since you have appended your library path, but it doesn't hurt to be explicit.
