# Miniconda

### What is Miniconda?

Fundamentally, Miniconda is a minimal installer for Conda, the package and environment manager originally built for the Anaconda Python/R distribution — a collection of packages optimized for data science. Conda is more than just a package manager however, it also creates and manages the environments that packages are installed in to. The usage of environments means you can have multiple versions of certain software installed in different environments and avoid conflicts or incompatibilities between software or dependencies. This is accomplished by installing packages into a separate directory which is then appended to your `PATH` when that environment is activated.

### Creating a new conda environment

Let's create an environment on Easley to run a python machine learning script that uses the TensorFlow library and the pandas library. Once you log in to Easley using `ssh` load the miniconda software module with the command:

`module load miniconda3/latest`

We use `conda` to create new environments and install/upgrade packages within environments. To create our machine learning environment we type:

`conda create --name TensorFlow python=3.11 pandas tensorflow`

Avoid pinning very old Python versions like 3.5 here. They're long past end-of-life, and asking conda to solve an environment against years of since-released package history can make dependency resolution extremely slow or effectively hang.

The command you are calling here is `conda` and you are telling it you want to `create` a new environment named TensorFlow with the packages python version 3.11 specifically, pandas, and tensorflow. When you enter this command `conda` prints out the plan for this environment to `stdout`:

```bash
conda create --name TensorFlow python=3.11 pandas tensorflow
```

```
## Package Plan ##

  environment location: /users/yourusername/.conda/envs/TensorFlow

  added / updated specs:
    - pandas
    - python=3.11
    - tensorflow


The following packages will be downloaded:

    package                     |            build
    ----------------------------|-----------------
    pandas-3.0.5                |  py311h8032f78_1        14.5 MB  conda-forge
    hdf5-2.1.0                  |nompi_h654f344_110         3.9 MB  conda-forge
    python-flatbuffers-25.12.19 |     pyh9d96877_0          35 KB  conda-forge
    ------------------------------------------------------------
                                           Total:        20.5 MB

The following NEW packages will be INSTALLED:

    keras:              conda-forge/noarch::keras-3.15.0-pyh753f3f9_0
    numpy:               conda-forge/linux-64::numpy-2.4.6-py311h2e04523_0
    pandas:             conda-forge/linux-64::pandas-3.0.5-py311h8032f78_1
    python:             conda-forge/linux-64::python-3.11.15-h7508c33_1_cpython
    tensorboard:        conda-forge/noarch::tensorboard-2.19.0-pyhd8ed1ab_0
    tensorflow:         conda-forge/linux-64::tensorflow-2.19.1-cpu_py311h7787b69_55
    tensorflow-base:    conda-forge/linux-64::tensorflow-base-2.19.1-cpu_py311hf06be6a_55
    ...

Proceed ([y]/n)?
```

This gives you the list of all packages you requested to be installed and their dependencies, as well as the package version and build. Of note is the environment location pathway at the top of the package plan, you will notice that `conda` by default installs into your local directory and does not need administrative access to install packages. This means that you can administer your own Conda environments at CARC. 

When you verify the package plan `conda` will proceed with downloading package binaries and installing them into the environment directory. You will see a progress display during installation and a message with how to activate your environment once complete:

```
Preparing transaction: done
Verifying transaction: done
Executing transaction: done
#
# To activate this environment, use
#
#     $ conda activate TensorFlow
#
# To deactivate an active environment, use
#
#     $ conda deactivate
#
```

Now we have our machine learning environment created to run our machine learning python script. To activate the environment we just created you use the command `source activate my_environment_name`, which is `source activate TensorFlow` for this example. Remember to include the lines below in your Slurm script when working with Conda environments:

```bash
# load miniconda software module
module load miniconda3/latest

# activate your desired conda environment
source activate environment_name
```
For more information on managing environments visit the Conda documentation site at this [link](https://conda.io/docs/user-guide/index.html), or by adding the flag `--help` to any `conda` command, for example, `conda create --help` will print a help page for creating environments.

