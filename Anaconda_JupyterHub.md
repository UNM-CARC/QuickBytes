# Using Custom Anaconda Environments in JupyterHub

Custom environments created by users can also be used on JupyterHub. This QuickByte shows you how to make them accessible on JupyterHub.

## In Terminal 

If you are creating an anaconda environment from scrach that you know you will want to use on JupyterHub, as you are creating the environment add the ipykernel to the packages you want included.

``` 
module load anaconda
conda create -npl npl ipykernel
```

Alternatively, if you already have an environment created and would like it to be available on JupyterHub, then add the ipykernal. 

``` 
source activate nlp
conda install ipykernel
```

Remember that you can also access the terminal though JupyterHub. To do this click Terminal under the New dropdown menu. 

![term_Jup](https://github.com/UNM-CARC/QuickBytes/blob/master/JuphuB_terminal.png)

## On JupyterHub

After your environments have been modified to include the ipykernal, you can open notebooks on JupyterHub by opening a New Notebook under File and selecting the environment. 

![term_Jup](https://github.com/UNM-CARC/QuickBytes/blob/master/JupHub_envi.png)
