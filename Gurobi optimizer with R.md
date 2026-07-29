# Gurobi optimizer with R

[Gurobi optimizer](https://www.gurobi.com/products/gurobi-optimizer/) is a problem solving software that can be used within R. It can solve integer, linear, and quadratic
programming optimizations. These techniques can help to find the answers to complex models. 


## Example of running Gurobi optimizer with R at CARC

There are modules for both Gurobi and R on the Easley cluster. All you need to do is load them, and then start an R
session. This command is for version 9.1.0, however there are other versions of gurobi available (enter `module avail gurobi` to see a full list).
```bash
username@easley-sn:~$ module load gurobi/9.1.0
username@easley-sn:~$ module load libdeflate/1.14-2pby r/4.5.2-pspo
username@easley-sn:~$ export LD_LIBRARY_PATH=$LIBDEFLATE_LIB:$LD_LIBRARY_PATH
username@easley-sn:~$ R
```

Note: `r/4.5.2-pspo` has a missing `libdeflate` runtime dependency, hence the extra `libdeflate` module load and `LD_LIBRARY_PATH` export above. See the known issue in `R_at_CARC/getting_R_software.md` for details. This is needed on a compute node in a Slurm job; it's not required when running R directly on the head node.

Once you have started an R session, you can install packages just as you would in R. If you ever run into issues loading 
packages in R at CARC, you can reach out for assistance by emailling help@carc.unm.edu. One piece of advice if you are using 
JupyterHub to run an R notebook at CARC is you may need to install packages from the terminal window on JupyterHub because 
the notebook will not let you interactively answer questions installs may need. 

Start by installing the gurobi package:
```
> install.packages('/opt/local/gurobi/9.1.0/linux64/R/gurobi_9.1-0_R_4.0.2.tar.gz')
```

```
Installing package into '/users/username/R/x86_64-pc-linux-gnu-library/4.5'
* installing *binary* package 'gurobi' ...
* DONE (gurobi)
```
You should now be able to load the gurobi library in an R session:
```
> library(gurobi)
```

```
Loading required package: slam
```
Note that if you get an error regarding slam, you can install it using the command:
```
install.packages("slam", repos = "https://cloud.r-project.org")
```
Now let's run a quick model as an example of what Gurobi can do and to see if everything is working properly: 
```r
model <- list()
model$A          <- matrix(c(1,2,3,1,1,0), nrow=2, ncol=3, byrow=T)
model$obj        <- c(1,1,2)
model$modelsense <- 'max'
model$rhs        <- c(4,1)
model$sense      <- c('<', '>')
model$vtype      <- 'B'
params <- list(OutputFlag=0)
result <- gurobi(model, params)
print('Solution:')
print(result$objval)
print(result$x)
```

Expected output:
```
[1] "Solution:"
[1] 3
[1] 1 0 1
```

**Known issue:** as of this writing, running the model above fails with:
```
Error: Error 10009: Failed to connect to token server 'license001.alliance.unm.edu' (port 41954) - license file '/opt/local/gurobi/9.1.0/license/gurobi.lic'.  Consult the Quick Start Guide for instructions on starting a token server.
```
This is a CARC-side infrastructure problem, not a doc or user error. `license001.alliance.unm.edu` resolves fine over DNS, but the license token server's port (41954) actively refuses the connection — nothing is listening on it. Every other step above (loading modules, installing the `gurobi` and `slam` R packages, `library(gurobi)`) works correctly; only the actual `gurobi()` solver call fails, and it fails the same way whether run on the head node or inside a Slurm job. If you hit this, it's not something you can fix on your end — contact help@carc.unm.edu.
