# Anaconda

### What is Anaconda?

Fundamentally, Anaconda is a distribution of Python and R with a collection of associated packages optimized for data science. The installation and management of these packages is handled with the Anaconda package manager Conda. Conda is more than just a package manager however, it also creates and manages the environments that packages are installed in to. The usage of environments means you can have multiple versions of certain software installed in different environments and avoid conflicts or incompatibilities between software or dependencies. This is accomplished by installing packages into a separate directory which is then appended to your `PATH` when that environment is activated.

### Creating a new conda environment

Let's create an environment on Wheeler to run a python machine learning script that uses the TensorFlow library, python version 3.5, and the pandas library. Once you log in to Wheeler using `ssh` load the anaconda software module with the command:

`module load anaconda3`

We use `conda` to create new environments and install/upgrade packages within environments. To create our machine learning environment we type:

`conda create --name TensorFlow python=3.5 pandas tensorflow`
This is better

The command you are calling here is `conda` and you are telling it you want to `create` a new environment named TensorFlow with the packages python version 3.5 specifically, pandas, and tensorflow. When you enter this command `conda` prints out the plan for this environment to `stdout`:

```bash
Solving environment: done

## Package Plan ##

  environment location: /users/yourusername/.conda/envs/TensorFlow

  added / updated specs:
    - pandas
    - python=3.5
    - tensorflow


The following packages will be downloaded:

    package                    |            build
    ---------------------------|-----------------
    certifi-2018.8.24          |           py35_1         139 KB
    termcolor-1.1.0            |           py35_1           7 KB
    pip-10.0.1                 |           py35_0         1.8 MB
    pytz-2018.5                |           py35_0         231 KB
    protobuf-3.6.0             |   py35hf484d3e_0         615 KB
    werkzeug-0.14.1            |           py35_0         426 KB
    astor-0.7.1                |           py35_0          43 KB
    libprotobuf-3.6.0          |       hdbcaa40_0         4.1 MB
    markdown-2.6.11            |           py35_0         104 KB
    mkl_fft-1.0.4              |   py35h4414c95_1         148 KB
    mkl_random-1.0.1           |   py35h629b387_0         364 KB
    tensorboard-1.10.0         |   py35hf484d3e_0         3.3 MB
    tensorflow-base-1.10.0     |mkl_py35h3c3e929_0        82.1 MB
    python-dateutil-2.7.3      |           py35_0         261 KB
    numpy-base-1.15.1          |   py35h81de0dd_0         4.2 MB
    wheel-0.31.1               |           py35_0          63 KB
    _tflow_1100_select-0.0.3   |              mkl           2 KB
    python-3.5.5               |       hc3d631a_4        28.3 MB
    setuptools-40.2.0          |           py35_0         571 KB
    grpcio-1.12.1              |   py35hdbcaa40_0         1.7 MB
    gast-0.2.0                 |           py35_0          15 KB
    absl-py-0.4.0              |   py35h28b3542_0         144 KB
    six-1.11.0                 |   py35h423b573_1          21 KB
    tensorflow-1.10.0          |mkl_py35heddcb22_0           4 KB
    pandas-0.23.4              |   py35h04863e7_0        10.0 MB
    numpy-1.15.1               |   py35h3b04361_0          37 KB
    ------------------------------------------------------------
                                           Total:       138.6 MB

The following NEW packages will be INSTALLED:

    _tflow_1100_select: 0.0.3-mkl
    absl-py:            0.4.0-py35h28b3542_0
    astor:              0.7.1-py35_0
    blas:               1.0-mkl
    ca-certificates:    2018.03.07-0
    certifi:            2018.8.24-py35_1
    gast:               0.2.0-py35_0
    grpcio:             1.12.1-py35hdbcaa40_0
    intel-openmp:       2018.0.3-0
    libedit:            3.1.20170329-h6b74fdf_2
    libffi:             3.2.1-hd88cf55_4
    libgcc-ng:          8.2.0-hdf63c60_1
    libgfortran-ng:     7.3.0-hdf63c60_0
    libprotobuf:        3.6.0-hdbcaa40_0
    libstdcxx-ng:       8.2.0-hdf63c60_1
    markdown:           2.6.11-py35_0
    mkl:                2018.0.3-1
    mkl_fft:            1.0.4-py35h4414c95_1
    mkl_random:         1.0.1-py35h629b387_0
    ncurses:            6.1-hf484d3e_0
    numpy:              1.15.1-py35h3b04361_0
    numpy-base:         1.15.1-py35h81de0dd_0
    openssl:            1.0.2p-h14c3975_0
    pandas:             0.23.4-py35h04863e7_0
    pip:                10.0.1-py35_0
    protobuf:           3.6.0-py35hf484d3e_0
    python:             3.5.5-hc3d631a_4
    python-dateutil:    2.7.3-py35_0
    pytz:               2018.5-py35_0
    readline:           7.0-ha6073c6_4
    setuptools:         40.2.0-py35_0
    six:                1.11.0-py35h423b573_1
    sqlite:             3.24.0-h84994c4_0
    tensorboard:        1.10.0-py35hf484d3e_0
    tensorflow:         1.10.0-mkl_py35heddcb22_0
    tensorflow-base:    1.10.0-mkl_py35h3c3e929_0
    termcolor:          1.1.0-py35_1
    tk:                 8.6.7-hc745277_3
    werkzeug:           0.14.1-py35_0
    wheel:              0.31.1-py35_0
    xz:                 5.2.4-h14c3975_4
    zlib:               1.2.11-ha838bed_2

Proceed ([y]/n)?
```

This gives you the list of all packages you requested to be installed and their dependencies, as well as the package version and build. Of note is the environment location pathway at the top of the package plan, you will notice that `conda` by default installs into your local directory and does not need administrative access to install packages. This means that you can administer your own Anaconda environments at CARC. 

When you verify the package plan `conda` will proceed with downloading package binaries and installing them into the environment directory. You will see the progress of installation and a message with how to activate your environment once complete:

```bash
Downloading and Extracting Packages
certifi-2018.8.24    |  139 KB | ####################################### | 100%
python-3.6.6         | 15.4 MB | ####################################### | 100%
tensorflow-base-1.10 | 55.3 MB | ####################################### | 100%
setuptools-40.2.0    |  554 KB | ####################################### | 100%
libprotobuf-3.6.0    |  3.8 MB | ####################################### | 100%
sqlite-3.24.0        |  2.2 MB | ####################################### | 100%
mkl-2018.0.3         | 149.2 MB| ###################################### | 100%
mkl_random-1.0.1     |  349 KB | ####################################### | 100%
mkl_fft-1.0.4        |  137 KB | ####################################### | 100%
openssl-1.0.2p       |  3.4 MB | ####################################### | 100%
six-1.11.0           |   21 KB | ####################################### | 100%
tensorflow-1.10.0    |    4 KB | ####################################### | 100%
numpy-base-1.15.1    |  4.0 MB | ####################################### | 100%
protobuf-3.6.0       |  604 KB | ####################################### | 100%
numpy-1.15.1         |   37 KB | ####################################### | 100%
intel-openmp-2018.0. | 1004 KB | ####################################### | 100%
absl-py-0.4.0        |  143 KB | ####################################### | 100%
tensorboard-1.10.0   |  3.3 MB | ####################################### | 100%
_tflow_1100_select-0 |    3 KB | ####################################### | 100%
Preparing transaction: done
Verifying transaction: done
Executing transaction: done
#
# To activate this environment, use:
# > source activate TensorFlow
#
# To deactivate an active environment, use:
# > source deactivate
#
```

Now we have our machine learning environment created to run our machine learning python script. To activate the environment we just created you use the command `source activate my_environment_name`, which is `source activate TensorFlow` for this example. Remember to include the lines below in your PBS script when working with Anaconda environments:

```bash
# load anaconda software module
module load anaconda3

# activate your desired anaconda environment
source activate environment_name
```
For more information on managing environments visit the Conda documentation site at this [link](https://conda.io/docs/user-guide/index.html), or by adding the flag `--help` to any `conda` command, for example, `conda create --help` will print a help page for creating environments.

