# Miniconda
### What is Miniconda?

At a basic level Miniconda is a minimal installer for Conda, the package and environment manager originally built for the Anaconda Python/R distribution. Rather than bundling hundreds of data science packages up front like the full Anaconda distribution does, Miniconda gives you just Conda itself and a small base environment, and you install only the packages you actually need from there. This is what CARC provides via the `miniconda3` module. The `anaconda3` module has been retired.

Conda is more than just a package manager however, it also creates and manages the environments that packages are installed in to. The use of environments to isolate software means you can have multiple versions of the same software installed in different environments and avoid conflicts or incompatibilities between software or dependencies. This is accomplished by installing packages into a separate directory which is then appended to your `PATH` when that environment is activated.

The next couple of pages will provide a brief introduction on how to use Conda to create and maintain locally administered environments on the CARC machines. 

For more information on the usage and various features of Conda, please visit their website at this [link](https://conda.io/docs/).
