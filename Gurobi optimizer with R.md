# Gurobi optimizer with R

[Gurobi optimizer](https://www.gurobi.com/products/gurobi-optimizer/) is a problem solving software that can be used within R. It can solve integer, linear, and quadratic
programming optimizations. These techniques can be helpful for finding the answers to complex models. 


## Example of running Gurobi optimizer with R at CARC

There are modules for both Gurobi and R on the Hopper cluster. All you need to do is load them, and then start an R
session. This command is for running version 9.1.0, the default version of Gurobi on Hopper. However, there are other versions of Gurobi available (enter `module avail gurobi` to see a full list).
```
username@hopper ~$ module load gurobi/9.1.0
username@hopper ~$ module load r
username@hopper ~$ srun --pty R
```
Once you have started an R session, you can install packages just as you would in R. If you ever run into issues loading 
packages in R at CARC, you can reach out for assistance by emailing help@carc.unm.edu. One piece of advice if you are using 
JupyterHub to run an R notebook at CARC is that you may need to install packages from the terminal window on JupyterHub because 
the notebook will not let you interactively answer questions installs may need. 

Start by installing the Gurobi package:
```
> install.packages('/opt/local/gurobi/9.1.0/linux64/R/gurobi_9.1-0_R_4.0.2.tar.gz')
```
If prompted to use a personal library, type `yes`. This will prompt you once more asking if you would like to create a personal library into your home directory. Type `yes` once more. Below is the expected output:
```
inferring 'repos = NULL' from 'pkgs'
* installing *binary* package 'gurobi' ...
* DONE (gurobi)
>
```
You should now be able to load the Gurobi library in an R session:
```
> library(gurobi)
Loading required package: slam
```
Note that if you get an error regarding slam, you can install it using the command:
```
install.packages("slam", repos = "https://cloud.r-project.org")
```
If you get an error regarding Matrix, you can install it using the command:
```
install.packages("Matrix", repos = "https://cloud.r-project.org")
```


Now let's run a quick model as an example of what Gurobi can do and to see if everything is working properly: 
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
