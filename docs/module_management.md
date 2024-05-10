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
----------------------------------------------------------------------------------------------------------------------------------------------------------
  intel:
----------------------------------------------------------------------------------------------------------------------------------------------------------
    Description:
      Intel Compiler Family (C/C++/Fortran for x86_64)

     Versions:
        intel/17.0.3.191
        intel/17.0.4.196
        intel/17.0.5.239
        intel/18.0.0.128
        intel/18.0.1.163
        intel/18.0.2.199
     Other possible modules matches:
        abinit-8.2.2-intel-17.0.4-impi-mkl-xz32k53  abinit-8.2.2-intel-18.0.0-impi-mkl-lck65q7  abyss-2.0.2-intel-17.0.4-openmpi-pf2axsd  abyss-2.0.2-intel-17.0.4-pf2axsd  ...

----------------------------------------------------------------------------------------------------------------------------------------------------------
  To find other possible module matches execute:

      $ module -r spider '.*intel.*'

----------------------------------------------------------------------------------------------------------------------------------------------------------
  For detailed information about a specific "intel" module (including how to load the modules) use the module's full name.
  For example:

     $ module spider intel/18.0.2.199
----------------------------------------------------------------------------------------------------------------------------------------------------------
```
This command returns much more detailed information on a module of interest. You can see that there are actually multiple versions of the Intel compilers available for use, as is the case for most software installed on CARC systems.

To see all currently loaded modules use the command `module list`. As an example, lets load the software module for the genome assembler Abyss, and then use `module list`:

```bash
module load abyss-2.0.2-intel-18.0.2-openmpi-mag4oti
module list

Currently Loaded Modules:
  1) ncurses-6.0-intel-18.0.2-crfixrx     5) libpciaccess-0.13.5-intel-18.0.2-etjmw6m   9) sparsehash-2.0.3-intel-18.0.2-wkrpmec
  2) readline-7.0-intel-18.0.2-v73wsy6    6) hwloc-1.11.8-intel-18.0.2-fjspqwm         10) bzip2-1.0.6-intel-18.0.2-fsqwhjw
  3) sqlite-3.21.0-intel-18.0.2-c66lylp   7) openmpi-3.0.0-intel-18.0.2-7ejspct        11) boost-1.66.0-intel-18.0.2-eoio7oh
  4) libxml2-2.9.4-intel-18.0.2-gyxifwh   8) libtool-2.4.6-intel-18.0.2-h4zy3we        12) abyss-2.0.2-intel-18.0.2-openmpi-mag4oti
```
As you can see there are many more modules loaded than just Abyss. These are the libraries and applications that are dependencies of Abyss.

Usually, modules are loaded as part of PBS script and subsequently unloaded automatically after the completion of that Job, so `module avail` and `module load` are the main commands you will be using. However, if you are working on a node interactively you may need to unload modules manually. The command `module unload modulename` will unload modules one at a time, for example `module unload ncurses-6.0-intel-18.0.2-crfixrx` only unloads ncurses but leaves the rest of the modules still loaded. To unload all modules use the command `module purge`.
