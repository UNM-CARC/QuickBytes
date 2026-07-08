# Miniconda

### What is Miniconda?

Fundamentally, Miniconda is a minimal distribution of Python and R with a collection of associated packages optimized for data science. The installation and management of these packages is handled with the Miniconda package manager Conda. While initially focused mainly on Python packages, the repositories hosted by Anaconda and others now house a large collection of non-Python packages.

Although the full version of this distribution is called Anaconda, CARC uses Miniconda instead. Miniconda includes only Conda and its dependencies, cutting out the large collection of pre-installed packages that come bundled with the full Anaconda distribution. This keeps the installation lean and lets you build up only the environment you actually need.

Conda is more than just a package manager, however — it also creates and manages the environments that packages are installed in. The usage of environments means you can have multiple versions of certain software installed in different environments and avoid conflicts or incompatibilities between software or dependencies. This is accomplished by installing packages into a separate directory, which is then appended to your `PATH` when that environment is activated.

### Creating a New Conda Environment

Let's create an environment on Easley to run a Python machine learning script that uses the TensorFlow library, Python version 3.11, and the pandas library. Once you log in to Easley using `ssh`, load the Miniconda software module with the command:

`module load miniconda3`

Before creating anything, it's worth seeing what environments already exist. Run:

`conda info --envs`

On a well-used cluster like Easley, this list is usually long — alongside your own environments (if you have any yet), you'll see a large number of shared environments maintained for specific research groups or commonly used software:

```bash
# conda environments:
#
base                     /opt/local/miniconda3
aligners                 /projects/shared/conda/envs/aligners
qiime2-amplicon-2026.1   /projects/shared/conda/envs/qiime2-amplicon-2026.1
r-4.5                    /projects/shared/conda/envs/r-4.5
...
TensorFlow               /users/yourusername/.conda/envs/TensorFlow
tf_env                   /users/yourusername/.conda/envs/tf_env
```

*(trimmed for brevity — a real listing shows many more shared and personal environments than this)*

The path tells you which of three kinds of environment you're looking at:

- **`base`**, at `/opt/local/miniconda3` — the default system environment, maintained by CARC. Every user can use whatever's installed there, but nobody besides CARC staff can modify it.
- **Shared project/software environments**, under `/projects/shared/conda/envs/` (like `aligners`, `qiime2-amplicon-2026.1`, `r-4.5` above) — maintained for specific research groups or widely used software stacks. Any user can typically use these, but modifying them requires access CARC or the owning group grants you, same as `base`.
- **Your own environments**, under `/users/yourusername/.conda/envs/` (like `TensorFlow` above) — these belong to you: only you can see or modify them. No other user on the cluster, including other members of your research group, has access to them by default.

You may also notice nothing here is marked with the asterisk `conda info --envs` normally uses to flag the active environment — that's expected before `conda init`/`conda activate` have run in a shell (more on that below). Once you activate an environment, it'll show the asterisk instead.

We use `conda` to create new environments and install or upgrade packages within environments. To create our machine learning environment, we type:

`conda create --name TensorFlow python=3.11 pandas tensorflow -y`

The command you are calling here is `conda` and you are telling it you want to `create` a new environment named TensorFlow with the packages Python version 3.11 specifically, pandas, and tensorflow. When you enter this command, `conda` prints out the plan for this environment to `stdout`:

```bash
## Package Plan ##

  environment location: /users/yourusername/.conda/envs/TensorFlow

  added / updated specs:
    - pandas
    - python=3.11
    - tensorflow


The following packages will be downloaded:

    package                    |            build
    ---------------------------|-----------------
    tensorflow-base-2.19.1     |cpu_py311hf06be6a_55       313.3 MB  conda-forge
    libtensorflow_cc-2.19.1    |  cpu_h944eb50_55       152.8 MB  conda-forge
    libtensorflow_framework-2.19.1|  cpu_he6e9716_55        10.0 MB  conda-forge
    tensorboard-2.19.0         |     pyhd8ed1ab_0         4.9 MB  conda-forge
    hdf5-2.1.0                 |nompi_h7d5651c_108         4.2 MB  conda-forge
    libprotobuf-6.33.5         |       h538a264_2         3.5 MB  conda-forge
    keras-3.15.0               |     pyh753f3f9_0         960 KB  conda-forge
    grpcio-1.78.1              |  py311h3aa0767_0         861 KB  conda-forge
    protobuf-6.33.5            |  py311h3f0a9aa_2         477 KB  conda-forge
    pandas-3.0.3               |  py311h8032f78_0                 conda-forge
    numpy-2.4.6                |  py311h2e04523_0                 conda-forge
    python-3.11.15             | h7508c33_1_cpython                 conda-forge
    ------------------------------------------------------------
                                           Total:       499.7 MB

The following NEW packages will be INSTALLED:

    keras:              3.15.0-pyh753f3f9_0
    numpy:              2.4.6-py311h2e04523_0
    pandas:             3.0.3-py311h8032f78_0
    pip:                26.1.2-pyh8b19718_0
    python:             3.11.15-h7508c33_1_cpython
    tensorboard:        2.19.0-pyhd8ed1ab_0
    tensorflow:         2.19.1-cpu_py311h7787b69_55
    tensorflow-base:    2.19.1-cpu_py311hf06be6a_55
    ... (plus a large set of shared-library dependencies)

Proceed ([y]/n)?
```

This gives you the list of all packages you requested to be installed, along with their dependencies, versions, and builds — the `-y` flag in the command above answers this prompt automatically, which is useful for non-interactive/scripted use. Of note is the environment location path at the top of the package plan — you will notice that `conda` by default installs into your local directory and does not need administrative access to install packages. This means that you can administer your own Miniconda environments at CARC.

When you verify the package plan, `conda` will proceed with downloading package binaries and installing them into the environment directory. You will see the progress of the installation and a message with how to activate your environment once complete:

```bash
tensorflow-base-2.19 | 313.3 MB  | ##################################### | 100%
libtensorflow_cc-2.1 | 152.8 MB  | ##################################### | 100%
libtensorflow_framew | 10.0 MB   | ##################################### | 100%
tensorboard-2.19.0   | 4.9 MB    | ##################################### | 100%
hdf5-2.1.0           | 4.2 MB    | ##################################### | 100%
libprotobuf-6.33.5   | 3.5 MB    | ##################################### | 100%
keras-3.15.0         | 960 KB    | ##################################### | 100%
grpcio-1.78.1        | 861 KB    | ##################################### | 100%
 ... (more hidden) ...
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
```

Now we have our machine learning environment created to run our machine learning Python script. To activate the environment we just created, use the command `conda activate my_environment_name`, which is `conda activate TensorFlow` for this example.

Before `conda activate` works in a given shell, Conda needs to have hooked itself into that shell's startup files — this is what `conda init` does. Run it once per account, not once per session:

`conda init bash`

This appends a block to your `~/.bashrc` that defines the `conda` shell function `activate`/`deactivate` depend on. You'll need to start a new shell (or `source ~/.bashrc`) for it to take effect, but after that it stays in place for every future login.

> **If you see `CondaError: Run 'conda init' before 'conda activate'`** — even if you've already run `conda init` in a previous session — it means the shell function `conda init` set up in your `~/.bashrc` didn't get loaded in this particular shell (compute-node shells from `srun --pty bash` don't always source `~/.bashrc` on entry). Run `source ~/.bashrc` (or start a fresh login shell) and try `conda activate` again. If you've genuinely never run `conda init` before, run `conda init bash` once first, then do the same.

Remember to include the lines below in your Slurm script when working with Miniconda environments:

```bash
# load miniconda software module
module load miniconda3

# activate your desired conda environment
conda activate environment_name
```

### Installing Packages with pip

Not all versions of all software have Conda packages available, especially for some Python libraries. pip, the Python package manager, is automatically installed by default in all environments created by Conda, and can install packages alongside those installed by Conda without conflict.

For example, say you need the library psutil, but you specifically need version 5.3.0. When you search for psutil using `conda` you get the following:

```bash
$ conda search psutil=5.3
Loading channels: done
# Name                       Version           Build  Channel
psutil                         5.3.1          py27_0  conda-forge
psutil                         5.3.1          py35_0  conda-forge
psutil                         5.3.1          py36_0  conda-forge
```

Unfortunately, there are no packages built for psutil version 5.3.0. However, we can use pip to install the version we want.

```bash
$ conda activate TensorFlow

(TensorFlow)$ pip install psutil==5.3.0
Collecting psutil==5.3.0
  Downloading psutil-5.3.0.tar.gz (397 kB)
  Installing build dependencies ... done
  Getting requirements to build wheel ... done
  Preparing metadata (pyproject.toml) ... done
Building wheels for collected packages: psutil
  Building wheel for psutil (pyproject.toml) ... done
  Created wheel for psutil: filename=psutil-5.3.0-cp311-cp311-linux_x86_64.whl size=196478 sha256=5f4ccd48280d6a22bb6051bb817aca3ea13054350be10f03b5108c41fd03d028
  Stored in directory: /users/yourusername/.cache/pip/wheels/48/22/8d/8eb3db8c6428c186935b671fea12a9197147cd9badcf89f727
Successfully built psutil
Installing collected packages: psutil
Successfully installed psutil-5.3.0

(TensorFlow)$ conda list | grep psutil
psutil                    5.3.0                    pypi_0    pypi
```

When installing packages using `pip` it is important to first activate the Conda environment that you want to install the package in, since pip is strictly a package manager and cannot modify Conda environments from outside that environment. You can see that our psutil package is version 5.3.0, just like we wanted. Under the `Build` and `Channel` columns, you'll see `pypi_0` and `pypi` instead of a real conda build string — that's how `conda list` flags a package that was actually installed by `pip`, since conda has no build metadata for it.

### Performance with Conda versus pip

One thing to note when installing packages is that it is always preferable to install necessary packages with `conda` first, and only then use `pip` to install packages that were not available through Miniconda repositories.

It is usually best practice to install needed packages and dependencies with `conda` and use `pip` to install any remaining packages that were not available, rather than the other way around.

### Adding Package Repositories (Channels)

Easley's Conda is already configured with `bioconda` as a default channel alongside `conda-forge`, so most bioinformatics packages install with no extra steps. For example, if you need the Burrows-Wheeler Aligner (bwa) for an Illumina sequencing pipeline, `conda install bwa` succeeds immediately:

```bash
$ conda install bwa

## Package Plan ##

  added / updated specs:
    - bwa

The following NEW packages will be INSTALLED:

  bwa                bioconda/linux-64::bwa-0.7.19-h577a1d6_1
  perl               conda-forge/linux-64::perl-5.32.1-7_hd590300_perl5
```

Sometimes, though, the package you need lives in a channel that *isn't* already configured. For example, GPU-accelerated PyTorch needs the `pytorch` channel — searching for it without specifying a channel fails:

```bash
$ conda search pytorch-cuda
Loading channels: done
No match found for: pytorch-cuda. Search: *pytorch-cuda*

PackagesNotFoundError: The following packages are not available from current channels:

  - pytorch-cuda

Current channels:

  - https://conda.anaconda.org/conda-forge/linux-64
  - https://conda.anaconda.org/conda-forge/noarch
  - https://conda.anaconda.org/nodefaults/linux-64
  - https://conda.anaconda.org/nodefaults/noarch
  - https://conda.anaconda.org/bioconda/linux-64
  - https://conda.anaconda.org/bioconda/noarch

To search for alternate channels that may provide the conda package you're
looking for, navigate to

    https://anaconda.org

and use the search bar at the top of the page.
```

We can search other channels that may have the package we're after using the `-c` flag:

```bash
$ conda search -c pytorch -c nvidia pytorch-cuda
```

Which yields results:

```bash
Loading channels: done
# Name                       Version           Build  Channel
pytorch-cuda                    11.6      h867d48c_0  pytorch
pytorch-cuda                    11.7      h67b0de4_0  pytorch
pytorch-cuda                    11.8      h7e8668a_3  pytorch
pytorch-cuda                    12.1      ha16c6d3_5  pytorch
pytorch-cuda                    12.4      hc786d27_6  pytorch
```

We can then install it with `conda install -c pytorch -c nvidia pytorch-cuda` and continue with our work. You can permanently add channels by appending your `.condarc` file either directly in a text editor, or with `conda` using the `config` command:

```bash
$ conda config --append channels pytorch
```

This will permanently add the channel to your configuration file, meaning Conda will automatically search it as well as the default channels when looking for packages.

### Further Reading

- Official Conda documentation: [conda.io/docs](https://conda.io/docs/)
- Conda getting-started guide: [docs.conda.io](https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html)
- Managing environments: [conda.io/docs/user-guide](https://conda.io/docs/user-guide/index.html) (or run `conda create --help`, or add `--help` to any `conda` command)
- Managing channels and installing with pip: [conda.io/docs/user-guide/tasks/manage-channels](https://conda.io/docs/user-guide/tasks/manage-channels.html)

*This quickbyte was validated on 7/7/2026.*
