# Miniconda

### What is Miniconda?

At a basic level, Miniconda is a minimal distribution of Python and R that provides access to collections of associated packages optimized specifically for data science, maintained in repositories. The installation and management of these packages is handled with the Miniconda package manager Conda. While initially focused mainly on Python packages, the repositories hosted by Anaconda and others now house a large collection of non-Python packages.

Although the full version of this distribution is called Anaconda, CARC uses Miniconda instead. Miniconda includes only Conda and its dependencies, cutting out the large collection of pre-installed packages that come bundled with the full Anaconda distribution. This keeps the installation lean and lets you build up only the environment you actually need.

Conda is more than just a package manager, however — it also creates and manages the environments that packages are installed in. The use of environments to isolate software means you can have multiple versions of the same software installed in different environments and avoid conflicts or incompatibilities between software or dependencies. This is accomplished by installing packages into a separate directory, which is then appended to your `PATH` when that environment is activated.

The following pages provide a brief introduction on how to use Conda to create and maintain locally administered environments on Easley:

- **Creating a New Conda Environment** — covers loading the Miniconda module and creating environments with `conda create`
- **Installing with pip and Adding Channels** — covers installing packages with pip and searching additional package repositories

For more information on the usage and various features of Conda, please visit the official Conda documentation at this [link](https://conda.io/docs/). A more comprehensive getting-started guide is also available at the Conda user guide [here](https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html).

*This quickbyte was validated on 6/23/2026.*
