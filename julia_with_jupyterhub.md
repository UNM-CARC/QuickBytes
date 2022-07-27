# Julia with Jupyter Hub

It is possible to use a Julia environment in the CARC Jupyter Hub.
To get Julia to appear as a Jupyter Notebook option, you must install a Julia package to your home directory. 
Follow the setup steps below to install the package.
Once the package is installed, you will not need to repeat the setup steps.


## Setup

First you must load the julia module:
```bash
$> module load julia
```
Next, start an interactive Julia session:
```bash
$> julia
```
Enter two commands into Julia to download the package:
```bash
julia> using Pkg
julia> Pkg.add("IJulia")
```

Exit Julia:
```bash
julia> exit()
```

Julia should now appear as an option in the Jupyter Hub.

## Selecting Julia in JupyterHub

1. Start a JupyterHub hub job.
2. In the upper right portion of the screen, click on the 'new' drop-down menu.
3. Select the Julia option.
