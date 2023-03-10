# Julia with Jupyter Hub

It is possible to use a Julia environment in the CARC Jupyter Hub.
To get Julia to appear as a Jupyter Notebook option, you must install the IJulia package to your home directory using a terminal. 
Follow the setup steps below to install the package.
Once the package is installed, you will not need to repeat the setup steps.


## Setup

First you must load the julia module. To see a list of available julia versions enter ```module spider julia```.
```bash
$> module load julia
```
Next, start an interactive Julia session:
```bash
$> julia
```
Enter two commands into Julia to download the IJulia package and build it:
```bash
julia> using Pkg
julia> Pkg.add("IJulia")
julia> Pkg.build("IJulia")
```

Exit Julia:
```bash
julia> exit()
```

Julia should now appear as an option in JupyterHub.

## Selecting Julia in JupyterHub

1. Start a JupyterHub job.
2. In the upper right portion of the screen, click on the 'new' drop-down menu.
3. Select the Julia option.
