# Installing with pip and adding channels
#### Installing packages with pip

Not all versions of all software have Conda packages available however, especially for some python libraries. Pip, the python package manager, is automatically installed by default in all environments created by Conda, and can install packages alongside those installed by Conda without conflict.  
For example, say you need the library psutil, but you specifically need version 5.3.0. When you search for psutil using `conda` you get the following:

```bash
$ conda search psutil=5.3
Loading channels: done
# Name                       Version           Build  Channel
psutil                         5.3.1          py27_0  conda-forge
psutil                         5.3.1          py35_0  conda-forge
psutil                         5.3.1          py36_0  conda-forge
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
One thing to note when installing packages is that it is always preferable to first install necessary packages with `conda` first, only then use `pip` to install only those packages that were not available through your configured Conda channels. 
It is usually best practice to install needed packages and dependencies with `conda` and use `pip` to install any remaining packages that were not available instead of vice versa.

#### Adding package repositories (channels)

Sometimes the default channels for Conda do not have the package you are looking for, but that does not mean it is necessarily unavailable entirely. CARC's `miniconda3` module is already configured with these default channels (check yours with `conda config --show channels`):

```bash
channels:
  - conda-forge
  - nodefaults
  - bioconda
```

Note that BioConda — a large repository of bioinformatics packages — is already a default channel here, unlike a stock Anaconda/Miniconda install. So a package like the Burrows-Wheeler Aligner (bwa), which lives in BioConda, is already found without specifying `-c bioconda`:

```bash
$ conda search bwa
Loading channels: done
# Name                  Version           Build  Channel
bwa                       0.7.17      hed695b0_6  bioconda
bwa                       0.7.17      hed695b0_7  bioconda
bwa                       0.7.17      pl5.22.0_0  bioconda
bwa                       0.7.18      h577a1d6_2  bioconda
bwa                       0.7.19      h577a1d6_0  bioconda
```

If you do need a package from a channel that isn't in that default list, add it with `-c <channel>`, for example `conda search -c nvidia <package>`. You can permanently add a channel to your configuration with:

```bash
$ conda config --append channels <channel-name>
```
This will permanently add that channel to your `.condarc` file, meaning Conda will automatically search it alongside conda-forge/bioconda when looking for packages.

For more information on managing channels and installing with pip please refer to the Conda support documentation at this [link](https://conda.io/docs/user-guide/tasks/manage-channels.html).
