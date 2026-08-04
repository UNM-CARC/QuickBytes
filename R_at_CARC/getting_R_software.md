# Running R on HPC systems (well, on CARC systems)

## Getting R in the first place

There are three options for accessing R at Carc and I will run through both approaches since there are pros and cons to each.
### Option 1
The first option is to activate an installed R module. When logged in to a CARC system you can use the `module avail` command to see which R versions are available. If you have a CARC account open a terminal and log in to follow along. 

```
yourusername@easley-sn$ module avail r/
```

which will print out the following:

```
------------ /opt/spack/share/spack/lmod/linux-rocky9-x86_64/Core -------------
   r/4.4.3-wsvf
   r/4.5.2-pspo (D)

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".
```

These are all of the currently available R modules installed on Easley. In order to activate a R software module you use the `module load` command. For example:

```
yourusername@easley-sn$ module load libdeflate/1.14-2pby r/4.5.2-pspo
yourusername@easley-sn$ export LD_LIBRARY_PATH=$LIBDEFLATE_LIB:$LD_LIBRARY_PATH
yourusername@easley-sn$ R
```

```
R version 4.5.2 (2025-10-31) -- "[Not] Part in a Rumble"
Copyright (C) 2025 The R Foundation for Statistical Computing
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

> 
```

Will load the current default R build (4.5.2). Normally you will be running R jobs in batch mode as opposed to interactively, which means you will have the `module load` command in your Slurm script, but we will get to that later. 

### Option 2
The second option is to create a custom local Miniconda environment with the version of R that would like to run. In order to do this you need to first load the Miniconda software module and then create a new environment according to your specifications. For example, the following commands will create a Miniconda environment with R 4.5:

```
yourusername@easley-sn$ module load miniconda3/latest
yourusername@easley-sn$ conda create --yes --name my_r_env r-base=4.5
```

```
...
Preparing transaction: done
Verifying transaction: done
Executing transaction: done
#
# To activate this environment, use
#
#     $ conda activate my_r_env
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```

Then to use your newly created R environment you need to 1) make sure you have the Miniconda3 software module loaded, and 2), activate your conda environment.

```
yourusername@easley-sn$ module load miniconda3/latest
yourusername@easley-sn$ source activate my_r_env
yourusername@easley-sn$ R
```

```
R version 4.5.2 (2025-10-31) -- "[Not] Part in a Rumble"
Copyright (C) 2025 The R Foundation for Statistical Computing
Platform: x86_64-conda-linux-gnu (64-bit)

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

> 
```
### Option 3

The third option is to use JupyterHub. To do so direct your browser to https://easley.alliance.unm.edu/jupyter or https://hopper.alliance.unm.edu/jupyter and log in with your CARC credentials. Click on the "New" drop down menu and select "R". Now you have a R session running through JupyterHub. 
