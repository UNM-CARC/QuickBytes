R Programming in HPC
====================

## What is R?
R is a programming language and a software environment for statistical computing and graphics techniques. This is widely used nowadays by statisticians and data miners for developing software tools required for data analysis. The R language is primarily derived from the S language developed at Bell Laboratories in 1975. R provides various tools and techniques for linear and nonlinear modelling, statistical tests, time series analysis, classification, clustering, etc. More history and documentation of R are available at this [link](https://cran.r-project.org/manuals.html)
## How to run R?
First, login to one of the CARC machines via SSH.

`ssh user@machine_name.alliance.unm.edu`

Once logged into the machine, load the default version of R provided by the CARC machine with: 

`module load r`

If you would like to see all available versions of R, run:

`module spider r`

To also load a specific version of R, use:

`module load r/<version>`

Note: Some versions of R may have compiler dependencies and require a compiler module such as GCC to be loaded first. If these dependencies are needed, the module system will display an error message when attempting to load the R module that includes a `module spider r/<version>` command that will help identify the required modules.

After loading the R module, begin R programming by typing

`srun --pty R`

This will show

```bash

R version 4.4.0 (2024-04-24) -- "Puppy Cup"
Copyright (C) 2024 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

```
This means the R module is loaded, and you are ready to use R for your research
## Running a sample script example.R 
Let us look at a sample script called "example.R" which will print "Hello World".
The script looks like 

```bash
# example.R
# Program to print Hello World

print('Hello World')
```
Before running the script, make sure you have exited the R interpreter (indicated by the `>` prompt) by typing `q()` and returning back to the Linux command line. In order to execute this script, type

`Rscript example.R`

This will give an output of

`[1] "Hello World"`

If you want to generate samples from a normal distribution, you can use the `rnorm()` function. Let's make some changes to the example.R script. 

```bash
# Program to print Hello World and to generate normal random numbers

print('Hello World')

# Calling the rnorm() function to generate three random numbers from a 
# normal distribution with mean 5 and a standard  deviation of 5

rnorm(3,mean=5,sd=5)
```

Execute the script again and look at the new output.

```bash
[1] "Hello World"
[1] 3.744463 7.954163 3.363275
```

