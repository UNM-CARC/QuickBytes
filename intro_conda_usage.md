#Working with Conda
###Using Conda to create a new environment

Let's start by logging in to Wheeler and create an empty environment. After creating a new environment we will then install Python 2.7 our newly created environment and explore what Conda is doing. To do this we must first load the module for Anaconda, in this case we will be using Anaconda3 which uses Python 3 by default. If you know that you are going to be using a lot of code written in Python 2 then you can load Anaconda instead of Anaconda3. 

```bash
$ module load anaconda3
$ conda create --name py-2.7
Solving environment: done

## Package Plan ##

  environment location: /users/yourusername/.conda/envs/py-2.7


Proceed ([y]/n)?

Preparing transaction: done
Verifying transaction: done
Executing transaction: done
#
# To activate this environment, use
#
#     $ conda activate MyFirstEnvironment
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```
We now have a new Conda environment that we can populate with whatever software we require for the analyses we wish to run.
###Installing packages with Conda
Now that we have our empty environment let's install Python 2.7 in it. Make sure you have the Anaconda3 module loaded and then type the following command:

```bash
$ conda install --name py-2.7 python=2.7
```
You should see the following print to `stdout`

```bash
## Package Plan ##

  environment location: /users/yourusername/.conda/envs/py-2.7

  added / updated specs:
    - python=2.7


The following packages will be downloaded:

    package                    |            build
    ---------------------------|-----------------
    pip-10.0.1                 |           py27_0         1.7 MB
    certifi-2018.8.24          |           py27_1         139 KB
    python-2.7.15              |       h1571d57_0        12.1 MB
    setuptools-40.2.0          |           py27_0         585 KB
    wheel-0.31.1               |           py27_0          62 KB
    tk-8.6.8                   |       hbc83047_0         3.1 MB
    readline-7.0               |       h7b6447c_5         392 KB
    ------------------------------------------------------------
                                           Total:        18.1 MB

The following NEW packages will be INSTALLED:

    ca-certificates: 2018.03.07-0
    certifi:         2018.8.24-py27_1
    libedit:         3.1.20170329-h6b74fdf_2
    libffi:          3.2.1-hd88cf55_4
    libgcc-ng:       8.2.0-hdf63c60_1
    libstdcxx-ng:    8.2.0-hdf63c60_1
    ncurses:         6.1-hf484d3e_0
    openssl:         1.0.2p-h14c3975_0
    pip:             10.0.1-py27_0
    python:          2.7.15-h1571d57_0
    readline:        7.0-h7b6447c_5
    setuptools:      40.2.0-py27_0
    sqlite:          3.24.0-h84994c4_0
    tk:              8.6.8-hbc83047_0
    wheel:           0.31.1-py27_0
    zlib:            1.2.11-ha838bed_2

Proceed ([y]/n)?


Downloading and Extracting Packages
pip-10.0.1           |  1.7 MB | ####################################### | 100%
certifi-2018.8.24    |  139 KB | ####################################### | 100%
python-2.7.15        | 12.1 MB | ####################################### | 100%
setuptools-40.2.0    |  585 KB | ####################################### | 100%
wheel-0.31.1         |   62 KB | ####################################### | 100%
tk-8.6.8             |  3.1 MB | ####################################### | 100%
readline-7.0         |  392 KB | ####################################### | 100%
Preparing transaction: done
Verifying transaction: done
Executing transaction: done
```
Now our py-2.7 environment actually has something in it that we can use. There are other ways to install packages in an environment, but they all use the `conda install` command. You can do what we did above and specify which environment you want to install in to, or you can activate the environment first and then install the package, as shown below:

```bash
$ py-2.7
(py-2.7)$ conda install python=2.7
```
You will notice that the name of the currently active environment now precedes your command prompt.   
We can also save time by installing our packages while we create our environment by listing the packages we want installed after the name of the environment we are creating, as shown below:

```bash
$ conda create --name py-2.7 python=2.7
```
These all accomplish the same goal of populating an environment with software, but what exactly is a Conda environment and what is it doing?

###What is a Conda environment?

What Conda does when it creates an environment is generate an isolated directory where software packages are installed, then, upon activation of that environment, it prepends our `PATH` to direct the computer to search in that environment directory first. To help visualize and understand what Conda is doing when it is creating an environment let's run a couple of Bash commands. Run the following commands, `which python`, `python --version`, and `echo $PATH` while you have the anaconda3 module loaded, but no environment activated. You should see the following print to `stdout`:

```bash
$ module load anaconda3
$ which python
/opt/local/anaconda3/5.2.0/bin/python
$ python --version
Python 3.6.5 :: Anaconda, Inc.
$ echo $PATH
/opt/local/anaconda3/5.2.0/bin:/users/yourusername/bin
```
You can see that we are using Python version 3.6.5 distributed by Anaconda which is located in the Anaconda `root` directory. You can also see that at the beginning of our `PATH` is that `root` directory. Now let's activate our py-2.7 environment and see how things change. 
 

```bash
$ source activate py-2.7
(py-2.7)$ which python
~/.conda/envs/py-2.7/bin/python
(py-2.7)$ python --version
Python 2.7.15 :: Anaconda, Inc.
(py-2.7)$ echo $PATH
/users/yourusername/.conda/envs/py-2.7/bin:/opt/local/anaconda3/5.2.0/bin:/users/yourusername/bin
```
As you can see we are now accessing Python version 2.7.15 distributed by Anaconda which is installed in the py-2.7 environment directory located in our home directory. By comparing the `PATH` before and after activating our environment you can see that Conda prepends our `PATH` to direct to your environment. This is fundamentally how Conda controls and manages environments. Once you deactivate an environment your `PATH` variable returns to its previous state.  

For more information on managing Conda environments please visit the Conda help documentation at this [link](https://conda.io/docs/user-guide/tasks/manage-environments.html).