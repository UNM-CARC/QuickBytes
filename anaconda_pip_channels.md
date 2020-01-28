# Installing with pip and adding channels
#### Installing packages with pip

Not all versions of all software have Conda packages available however, especially for some python libraries. Pip, the python package manager, is automatically installed by default in all environments created by Conda, and can install packages alongside those installed by Conda without conflict.  
For example, say you need the library psutil, but you specifically need version 5.3.0. When you search for psutil using `conda` you get the following:

```bash
$ conda search psutil=5.3
Loading channels: done
# Name                  Version           Build  Channel
psutil                    5.3.1          py27_0  conda-forge
psutil                    5.3.1  py27h4c169b4_0  pkgs/main
psutil                    5.3.1          py35_0  conda-forge
psutil                    5.3.1  py35h6e9e629_0  pkgs/main
psutil                    5.3.1          py36_0  conda-forge
psutil                    5.3.1  py36h0e357b8_0  pkgs/main
```

Unfortunately there are no packages built for psutil version 5.3.0. We can use pip to install the version we want however.

```bash
$ source activate py-2.7

(py-2.7)$ pip install psutil==5.3.0
Collecting psutil==5.3.0
  Downloading https://files.pythonhosted.org/packages/1c/da/555e3ad3cad30f30bcf0d539cdeae5c8e7ef9e2a6078af645c70aa81e418/psutil-5.3.0.tar.gz (397kB)
    100% |████████████████████████████████| 399kB 1.3MB/s
Building wheels for collected packages: psutil
  Running setup.py bdist_wheel for psutil ... done
  Stored in directory: /users/yourusername/.cache/pip/wheels/ff/c5/4f/1ee2208203f1cfeda16e91fccd8bfce5f4840b683671729d57
Successfully built psutil

(py-2.7)$ conda list

# packages in environment at /users/yourusername/.Conda/envs/py-2.7:
#
# Name                    Version                   Build
ca-certificates           2018.03.07                    0
certifi                   2018.8.24                py27_1
libedit                   3.1.20170329         h6b74fdf_2
libffi                    3.2.1                hd88cf55_4
libgcc-ng                 8.2.0                hdf63c60_1
libstdcxx-ng              8.2.0                hdf63c60_1
ncurses                   6.1                  hf484d3e_0
openssl                   1.0.2p               h14c3975_0
pip                       10.0.1                   py27_0
**psutil                  5.3.0                     <pip>
python                    2.7.15               h1571d57_0
readline                  7.0                  h7b6447c_5
setuptools                40.2.0                   py27_0
sqlite                    3.24.0               h84994c4_0
tk                        8.6.8                hbc83047_0
wheel                     0.31.1                   py27_0
zlib                      1.2.11               ha838bed_2
```
When installing packages using `pip` it is important to first activate the Conda environment that you want to install the package in since pip is strictly a package manager and cannot modify Conda environments from outside that environment. You can see that our psutil package, marked with a double asterisk, is version 5.3.0, just like we wanted. Under the 'build' column however you will see that `conda` is not sure which build it is since it was installed with `pip`, as indicated by the `<pip>` designator.
#### Performance with Conda versus Pip
One thing to note when installing packages is that it is always preferable to first install necessary packages with `conda` first, only then use `pip` to install only those packages that were not available through Anaconda repositories. 
It is usually best practice to install needed packages and dependencies with `conda` and use `pip` to install any remaining packages that were not available instead of vice versa.

#### Adding package repositories (channels)

Sometimes the default repositories, or channels for Conda, do not have the package you are looking for, but that does not mean that it is necessarily unavailable entirely. Say you are working with some Illumina sequence data and need the Burrows-Wheeler Aligner (bwa) in your pipeline, so you activate your bioinformatics environment and type `conda install bwa` which prints the following:

```bash
Solving environment: failed

PackagesNotFoundError: The following packages are not available from current channels:

  - bwa

Current channels:

  - https://repo.anaconda.com/pkgs/main/linux-64
  - https://repo.anaconda.com/pkgs/main/noarch
  - https://repo.anaconda.com/pkgs/free/linux-64
  - https://repo.anaconda.com/pkgs/free/noarch
  - https://repo.anaconda.com/pkgs/r/linux-64
  - https://repo.anaconda.com/pkgs/r/noarch
  - https://repo.anaconda.com/pkgs/pro/linux-64
  - https://repo.anaconda.com/pkgs/pro/noarch

To search for alternate channels that may provide the conda package you're
looking for, navigate to

    https://anaconda.org

and use the search bar at the top of the page.
```
We can search other channels that may have the package we are interested in with the `-c` flag. For example, BioConda is a large repository that hosts several thousand bioinformatics packages. We can search for our bwa package by specifying that channel.

```bash
$ conda search -c bioConda bwa
```

Which yields better results:

```bash
Loading channels: done
# Name                  Version           Build  Channel
bwa                       0.5.9               0  bioConda
bwa                       0.5.9               1  bioConda
bwa                       0.6.2               0  bioConda
bwa                       0.6.2               1  bioConda
bwa                      0.7.3a               0  bioConda
bwa                      0.7.3a               1  bioConda
bwa                      0.7.3a      ha92aebf_2  bioConda
bwa                       0.7.4      ha92aebf_0  bioConda
bwa                       0.7.8               0  bioConda
bwa                       0.7.8               1  bioConda
bwa                       0.7.8      ha92aebf_2  bioConda
bwa                      0.7.12               0  bioConda
bwa                      0.7.12               1  bioConda
bwa                      0.7.13               0  bioConda
bwa                      0.7.13               1  bioConda
bwa                      0.7.15               0  bioConda
bwa                      0.7.15               1  bioConda
bwa                      0.7.16      pl5.22.0_0  bioConda
bwa                      0.7.17      ha92aebf_3  bioConda
bwa                      0.7.17      pl5.22.0_0  bioConda
bwa                      0.7.17      pl5.22.0_1  bioConda
bwa                      0.7.17      pl5.22.0_2  bioConda
```

We can then install our bwa package using `conda install -c bioConda bwa` and continue with our analyses. You can permanently add channels by appending your `.condarc` file either directly in a text editor, or with `conda` by using the `config` command:

```bash
$ conda config --append channels bioconda
```
This will permanently add the BioConda channel to your configuration file meaning Conda will automatically search BioConda as well as the default channels when looking for packages.

For more information on managing channels and installing with pip please refer to the Conda support documentation at this [link](https://conda.io/docs/user-guide/tasks/manage-channels.html).
