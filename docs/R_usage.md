R Programming in HPC
====================

## What is R?
R is a programming language and a software environment for statistical computing and graphics techniques. This is widely used now a days by statisticians and data miners for developing software tools required for data analysis. The R language is primarily derived from the S language developed at Bell Laboratories in 1975. R provides various tools and techniques for linear and nonlinear modelling, statistical tests, time series analysis, classification, clustering etc. More history and documentation of R are available at this [link](https://cran.r-project.org/manuals.html)
## How to run R?
First login to one of the CARC machines via SSH.

`ssh -X user@machine_name.alliance.unm.edu`

Once logged into the machine, you have to load the module which has R program files. 

`module load r-3.5.0-gcc-4.8.5-python2-khqxja7`

After loading the R module, begin R programming by typing

`R`

This will shows

```bash

R version 3.5.0 (2018-04-23) -- "Joy in Playing"
Copyright (C) 2018 The R Foundation for Statistical
Computing
Platform: x86_64-pc-linux-gnu (64-bit)

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
This means the R module is loaded and you are ready to use R for your research
## Running a sample script example.R 
Let us look a sample script, example.R which will print "Hello World"
The script looks like 

```bash
# Program to print Hello World

print('Hello World')
```
In order to execute this script, type

`Rscript example.R`

This will give an output of

`[1] "Hello World"`

If you want to generate samples from a normal distribution, you can use the `rnorm()` function. Let's make some change to the example.R script. 

```bash
# Program to print Hello World and to generate normal random numbers

print('Hello World')

#Calling the rnorm() function to generate three random numbers from a 
normal distribution with mean 5 and a standard  deviation of 5

rnorm(3,mean=5,sd=5)
```

Execute the script again and the look at the new output.

```bash
[1] "Hello World"
[1] 3.744463 7.954163 3.363275
```