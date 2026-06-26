# Managing software models

### Modules

There are many software packages installed on CARC systems, as well as standard built-in functions native to Unix. In order to manage these additional software packages, the CARC systems use modules. These modules set the appropriate environment variables and dependencies for software optimization and to avoid conflicts with other software.  
For more information, visit [this page](https://lmod.readthedocs.io/en/latest/010_user.html), or use the command `module man`.

### Using modules for setting application environments

Modules are used to set environment variables and dependencies for the purpose of managing access to applications and libraries on CARC systems. The command `module avail` lists all the modules available on the system you are logged in to. To load a module, use the `module load` command. For example, to load the module for the Intel compiler, use the command:

```bash
 module load intel
```
Another useful command related to module management is `module spider`. For example, if we issue the command `module spider intel` you will see the output:


```bash
--------------------------------------------------------------------------------------------------------------------
  intel:
--------------------------------------------------------------------------------------------------------------------
     Versions:
        intel/18.0.4
        intel/19.0.5
        intel/20.0.4
     Other possible modules matches:
        intel-mkl  intel-mpi  intel-oneapi-compilers  intel-oneapi-mkl  intel-oneapi-mpi  intel-oneapi-runtime  ...

--------------------------------------------------------------------------------------------------------------------
  To find other possible module matches execute:

      $ module -r spider '.*intel.*'

--------------------------------------------------------------------------------------------------------------------
  For detailed information about a specific "intel" package (including how to load the modules) use the module's full na
me.
  Note that names that have a trailing (E) are extensions provided by other modules.
  For example:

     $ module spider intel/20.0.4
--------------------------------------------------------------------------------------------------------------------
```
This command returns much more detailed information on a module of interest. You can see that there are actually multiple versions of the Intel compilers available for use, as is the case for most software installed on CARC systems.

To see all currently loaded modules use the command `module list`. For example, load the software module for openmpi and gcc using `module load openmpi gcc`, and then use `module list`:

```bash
module load openmpi gcc
module list
Currently Loaded Modules:
  1) gcc/14.1.0-vgbo   2) openmpi/5.0.6-lcny
```

Usually, modules are loaded as part of Slurm script and subsequently unloaded automatically after the completion of that Job, so `module avail` and `module load` are the main commands you will be using. However, if you are working on a node interactively you may need to unload modules manually. The command `module unload modulename` will unload modules one at a time, for example `module unload ncurses-6.0-intel-18.0.2-crfixrx` only unloads ncurses but leaves the rest of the modules still loaded. To unload all modules use the command `module purge`.

*This quickbyte was validated on 6/26/2026*
