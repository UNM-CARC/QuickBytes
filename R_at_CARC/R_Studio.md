## R Studio
If you want to use R Studio on the CARC systems, there is a way to do it with X11 forwarding. 

First, you should either watch the X11 forwarding tutorial:

https://www.youtube.com/watch?v=-5ic9JWHuqI&list=PLvr5gRBLi7VAzEB_t5aXOLHLfdIu2s1hZ&index=14

Or you can read it:

https://github.com/UNM-CARC/QuickBytes/blob/master/X11_forwarding.md

Then you will need to create a conda environment with R and R studio. You can do so with these commands:

`module load miniconda3` \
`conda create --name rstudio --channel r rstudio`

You will type `y` for the conda environment to install. Once it is finished, type:

`conda activate rstudio`

Once you have the environment activated, you can run a Slurm job with the following command:

`srun --x11 --partition debug rstudio`

Note: this was done on Hopper, if you are on a different cluster you will need to change the partition name. 
