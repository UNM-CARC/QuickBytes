# Gurobi optimizer with R

[Gurobi optimizer](https://www.gurobi.com/products/gurobi-optimizer/) is a problem solving software that can be used within R. It can solve integer, linear, and quadratic
programming optimizations. These techniques can help to find the answers to complex models. 


## Example of running Gurobi optimizer with R at CARC

There are modules for both Gurobi and R on the wheeler cluster. All you need to do is load them, and then start an R
session. 

```
username@wheeler-sn:~$ module load gurobi
username@wheeler-sn:~$ module load r-3.6.0-gcc-7.3.0-python2-7akol5t
username@wheeler-sn:~$ R
```

Once you have started an R session, you can install packages just as you would in R. If you ever run into issues loading 
packages in R at CARC, you can reach out for assistance by emailling help@carc.unm.edu. One piece of advice if you are using 
JupyterHub to run an R notebook at CARC is you may need to install packages from ther terminal window on JupyterHub because 
the notebook will not let you interactiively answer questions installs may need. 

Go to your home directory and open your .bashrc to edit. Inside you will need to add these lines:
```
export GUROBI_HOME=$GUROBI_HOME:/opt/local/gurobi/8.1.0/linux64/
export PATH=$PATH:/opt/local/gurobi/8.1.0/linux64/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/local/gurobi/8.1.0/linux64/lib
```
Save these changes to your .bashrc file and in the command line enter:
```
source .bashrc
```
You should now be able to load the gurobi library in an R session:
```

Start by installing the gurobi package:
```
> install.packages('/opt/local/gurobi/8.1.0/linux64/R/gurobi_8.1-0_R_3.5.0.tar.gz')
Installing package into '/users/mfricke/R/x86_64-pc-linux-gnu-library/3.6'
* installing *binary* package 'gurobi' ...
* DONE (gurobi)
```

> library(gurobi)
Loading required package: slam
```
Note that if you get an error regarding slam, you can install it using the command:
```
install.packages("slam", repos = "https://cloud.r-project.org")
```
Now let's runs a quick model as an example of what Gurobi can do and to see if everything is working properly: 
```
> model <- list()
> model$A          <- matrix(c(1,2,3,1,1,0), nrow=2, ncol=3, byrow=T)
> model$obj        <- c(1,1,2)
> model$modelsense <- 'max'
> model$rhs        <- c(4,1)
> model$sense      <- c('<', '>')
> model$vtype      <- 'B'
> params <- list(OutputFlag=0)
> result <- gurobi(model, params)
> print('Solution:')
[1] "Solution:"
> print(result$objval)
[1] 3
> print(result$x)
[1] 1 0 1
```
