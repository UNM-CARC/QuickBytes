# Managing software modules

### Modules

There are many software packages installed on CARC systems, as well as standard built-in functions native to Unix. To manage these additional software packages, CARC systems use modules. These modules set the appropriate environment variables and dependencies for software optimization and to avoid conflicts with other software.

For more information, visit [this page](https://lmod.readthedocs.io/en/latest/010_user.html), or use the command `module help`.

### Using modules to set application environments

Modules are used to set environment variables and dependencies for the purpose of managing access to applications and libraries on CARC systems. The command `module avail` lists all the modules available on the system you are logged into. Note that this list can be extremely long — if you'd like to stop it from printing, use Ctrl+C (this works the same way on Mac, Windows, and Linux terminals, since you're connected to a remote Linux system either way).

To load a module, use the `module load` command. For example, to load the module for the Intel compilers, use the command:

```bash
module load intel-oneapi-compilers
```

Note that there's no plain `intel` module on Easley — `module load intel` fails with "The following module(s) are unknown." Easley's Intel software all lives under the `intel-oneapi-*` family instead (`intel-oneapi-compilers`, `intel-oneapi-mkl`, `intel-oneapi-mpi`, etc.).

Another useful command related to module management is `module spider`. For example, if you issue the command:

```bash
module spider intel
```

you will see output similar to:

```
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  intel-oneapi-advisor:
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     Versions:
        intel-oneapi-advisor/2025.2.0-asm7
        intel-oneapi-advisor/2025.2.0-omxu
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  For detailed information about a specific "intel-oneapi-advisor" package (including how to load the modules) use the module's full name.
  ...

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  intel-oneapi-compilers: intel-oneapi-compilers/2025.1.1-b3qi
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    This module can be loaded directly: module load intel-oneapi-compilers/2025.1.1-b3qi
...
```

`spider` matches on partial names, so searching `intel` surfaces the entire `intel-oneapi-*` family at once — you can see there are multiple related Intel packages available, each with its own version(s), as is the case for most software installed on CARC systems.

To see all currently loaded modules, use the command `module list`. As an example, let's load the software modules for OpenMPI and GCC, then use `module list`:

```bash
module load openmpi gcc
```

```bash
module list
```

```
Currently Loaded Modules:
  1) miniconda3/latest             3) gcc/14.2.0-j33x             5) openmpi/4.1.7-762w
  2) binutils/2.43.1-ifi2qjn (H)   4) openssh/9.9p1-d4o73h6 (H)
  Where:
   H:  Hidden Module
```

Modules are usually loaded as part of a Slurm script, and that environment doesn't persist beyond the job, so `module avail` and `module load` are the main commands you'll be using day to day. However, if you're working on a node interactively, you may need to unload modules manually. The command `module unload modulename` unloads modules one at a time — for example, after loading the modules above:

```bash
module unload openssh
```

```
Lmod Warning: 
--------------------------------------------------------------------------------------------------------
The following dependent module(s) are not currently loaded: openssh/9.9p1-d4o73h6 (required by:
openmpi/4.1.7-762w)
--------------------------------------------------------------------------------------------------------
```

This warning is expected and can be safely ignored — Lmod is just noting that OpenMPI normally depends on OpenSSH, but it doesn't stop the module from being unloaded. Running `module list` again confirms OpenSSH is gone while the rest remain loaded:

```bash
module list
```

```
Currently Loaded Modules:
  1) binutils/2.43.1-ifi2qjn (H)   2) gcc/14.2.0-j33x   3) openmpi/4.1.7-762w
  Where:
   H:  Hidden Module
```

To unload all modules at once, use the command:

```bash
module purge
```

*This quickbyte was validated on 6/22/2026*
