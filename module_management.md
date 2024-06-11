# Managing software models

### Modules

There are many software packages installed on CARC systems, as well as standard built-in functions native to Unix. In order to manage these additional software packages, the CARC systems use modules. These modules set the appropriate environment variables and dependencies for software optimization and to avoid conflicts with other software.  
For more information, visit [this page](https://lmod.readthedocs.io/en/latest/010_user.html), or use the command `module man`.

### Using modules for setting application environments

Modules are used to set environment variables and dependencies for the purpose of managing access to applications and libraries on CARC systems. The command `module avail` lists all the modules available on the system you are logged in to. To load a module, use the `module load <MODULE>` command. For example, to load the module for the Intel compiler, use the command:


    module load intel

Another useful command related to module management is `module spider <MODULE>`. For example, if we issue the command `module spider intel` you will see the output:

    [rdscher@hopper ~]$ module spider intel
    --------------------------------------------------------------------------------------------------------------------------------------------------------
      intel:
    --------------------------------------------------------------------------------------------------------------------------------------------------------
        Versions:
            intel/18.0.4
            intel/19.0.5
            intel/20.0.4
        Other possible modules matches:
            intel-mkl  intel-mpi  intel-oneapi-compilers  intel-oneapi-mkl  intel-oneapi-mpi  intel-oneapi-tbb  intel-parallel-studio  intel-tbb

    --------------------------------------------------------------------------------------------------------------------------------------------------------
      To find other possible module matches execute:

          $ module -r spider '.*intel.*'

    --------------------------------------------------------------------------------------------------------------------------------------------------------
      For detailed information about a specific "intel" package (including how to load the modules) use the module's full name.
      Note that names that have a trailing (E) are extensions provided by other modules.
      For example:

        $ module spider intel/20.0.4
    --------------------------------------------------------------------------------------------------------------------------------------------------------

This command returns much more detailed information on a module of interest. You can see that there are actually multiple versions of the Intel compilers available for use, as is the case for most software installed on CARC systems.

To see all currently loaded modules use the command `module list`. As an example, lets load the software module for the genome assembler Abyss, and then use `module list`:

    [rdscher@hopper ~]$ module load intel
    [rdscher@hopper ~]$ module list

    Currently Loaded Modules:
      1) intel-parallel-studio/cluster.2020.4-2xch   2) intel/20.0.4

As you can see, we not only loaded the intel module, but also the intel-parallel-studio module. Some modules such as `intel/20.0.4` have other modules they depend on. If they're able to load without issue, they will be loaded automatically without even telling you. If loading a new module would cause a discrepency, it will explain this to you;

    [rdscher@hopper ~]$ module load gcc

    Lmod is automatically replacing "intel/20.0.4" with "gcc/13.2.0-4u2z".

Use the module spider commmand with the full name of a module for more detailed information about the module;

    [rdscher@hopper ~]$ module spider gcc/13.2.0-4u2z
    --------------------------------------------------------------------------------------------------------------------------------------------------------
      gcc: gcc/13.2.0-4u2z
    --------------------------------------------------------------------------------------------------------------------------------------------------------

        This module can be loaded directly: module load gcc/13.2.0-4u2z

        Help:
          The GNU Compiler Collection includes front ends for C, C++, Objective-C,
          Fortran, Ada, and Go, as well as libraries for these languages.

You can get more information about a particular module with the `module show` command. This will tell you information such as the version, description, dependencies, any compilation flags, and also all of the environment variables that are set each time you load the modules. 

    [rdscher@hopper ~]$ module show gcc
    --------------------------------------------------------------------------------------------------------------------------------------------------------
      /opt/spack/share/spack/lmod/linux-rocky8-x86_64/Core/gcc/13.2.0-4u2z.lua:
    --------------------------------------------------------------------------------------------------------------------------------------------------------
    whatis("Name : gcc")
    whatis("Version : 13.2.0")
    whatis("Target : skylake_avx512")
    whatis("Short description : The GNU Compiler Collection includes front ends for C, C++, Objective-C, Fortran, Ada, and Go, as well as libraries for these la
    nguages.")
    whatis("Configure options : --with-pkgversion=Spack GCC --with-bugurl=https://github.com/spack/spack/issues --disable-multilib --enable-languages=c,c++,fort
    ran --disable-nls --disable-canonical-system-headers --with-system-zlib --with-zstd-include=/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/zstd-
    1.5.5-5u6wcdclqi2dkvywog6tdiogof44hzao/include --with-zstd-lib=/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/zstd-1.5.5-5u6wcdclqi2dkvywog6tdio
    gof44hzao/lib --enable-bootstrap --with-mpfr-include=/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/mpfr-4.2.0-7jwbkivx5czi2h3ykprp4tohgopcd75w/
    include --with-mpfr-lib=/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/mpfr-4.2.0-7jwbkivx5czi2h3ykprp4tohgopcd75w/lib --with-gmp-include=/opt/s
    pack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gmp-6.2.1-5kcxnes6uun5zrw4ulnwvzotqb3sfhtv/include --with-gmp-lib=/opt/spack/opt/spack/linux-rocky8-sky
    lake_avx512/gcc-8.5.0/gmp-6.2.1-5kcxnes6uun5zrw4ulnwvzotqb3sfhtv/lib --with-mpc-include=/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/mpc-1.3.1
    -lh7yitwjlqfhk7ljdkubef6wfhk5izxk/include --with-mpc-lib=/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/mpc-1.3.1-lh7yitwjlqfhk7ljdkubef6wfhk5iz
    xk/lib --without-isl --with-stage1-ldflags=-Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje
    /lib -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/lib64 -Wl,-rpath,/opt/spack/opt/spack
    /linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-runtime-8.5.0-ifampldlu2tf3ukzkt3yctwksoevqveh/lib -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gc
    c-8.5.0/gmp-6.2.1-5kcxnes6uun5zrw4ulnwvzotqb3sfhtv/lib -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/mpc-1.3.1-lh7yitwjlqfhk7ljdkube
    f6wfhk5izxk/lib -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/mpfr-4.2.0-7jwbkivx5czi2h3ykprp4tohgopcd75w/lib -Wl,-rpath,/opt/spack/
    opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/zlib-ng-2.1.5-3dux7kld3g4d7nbocdop73btjyydoagu/lib -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx5
    12/gcc-8.5.0/zstd-1.5.5-5u6wcdclqi2dkvywog6tdiogof44hzao/lib --with-boot-ldflags=-Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-1
    3.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/lib -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje
    /lib64 -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-runtime-8.5.0-ifampldlu2tf3ukzkt3yctwksoevqveh/lib -Wl,-rpath,/opt/spack/op
    t/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gmp-6.2.1-5kcxnes6uun5zrw4ulnwvzotqb3sfhtv/lib -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc
    -8.5.0/mpc-1.3.1-lh7yitwjlqfhk7ljdkubef6wfhk5izxk/lib -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/mpfr-4.2.0-7jwbkivx5czi2h3ykprp4
    tohgopcd75w/lib -Wl,-rpath,/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/zlib-ng-2.1.5-3dux7kld3g4d7nbocdop73btjyydoagu/lib -Wl,-rpath,/opt/spa
    ck/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/zstd-1.5.5-5u6wcdclqi2dkvywog6tdiogof44hzao/lib -static-libstdc++ -static-libgcc --with-build-config=spac
    k")
    help([[Name   : gcc]])
    help([[Version: 13.2.0]])
    help([[Target : skylake_avx512]])
    ]])
    help([[The GNU Compiler Collection includes front ends for C, C++, Objective-C,
    Fortran, Ada, and Go, as well as libraries for these languages.]])
    family("compiler")
    prepend_path("MODULEPATH","/opt/spack/share/spack/lmod/linux-rocky8-x86_64/gcc/13.2.0")
    prepend_path("CMAKE_PREFIX_PATH","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/.")
    prepend_path("PATH","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/bin")
    prepend_path("LD_LIBRARY_PATH","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/lib")
    prepend_path("LD_LIBRARY_PATH","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/lib64")
    prepend_path("MANPATH","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/share/man")
    prepend_path("PATH","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/bin")
    prepend_path("MANPATH","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/share/man")
    prepend_path("CMAKE_PREFIX_PATH","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/.")
    setenv("CC","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/bin/gcc")
    setenv("CXX","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/bin/g++")
    setenv("FC","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/bin/gfortran")
    setenv("F77","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/bin/gfortran")
    setenv("GCC_BIN","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/bin")
    setenv("GCC_INC","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/include")
    setenv("GCC_LIB","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje/lib64")
    setenv("GCC_ROOT","/opt/spack/opt/spack/linux-rocky8-skylake_avx512/gcc-8.5.0/gcc-13.2.0-4u2zyp4mueiw2vfc2uewq2xyzgoykbje")
    append_path("MANPATH","")

You can also use the `module unload <MODULE>` command to unload a speciifc module, or module purge to unload every module you have loaded;

    [rdscher@hopper ~]$ module list

    Currently Loaded Modules:
      1) intel-parallel-studio/cluster.2020.4-2xch   2) intel/20.0.4   3) ghcup/Ghcup   4) intel-mpi/2019.10.317-yz75   5) intel-mkl/2020.4.304-ewsd



    [rdscher@hopper ~]$ module unload intel-mpi
    [rdscher@hopper ~]$ module list

    Currently Loaded Modules:
      1) intel-parallel-studio/cluster.2020.4-2xch   2) intel/20.0.4   3) ghcup/Ghcup   4) intel-mkl/2020.4.304-ewsd



    [rdscher@hopper ~]$ module purge
    [rdscher@hopper ~]$ module list
    No modules loaded

Usually, modules are loaded as part of a slurm script and subsequently unloaded automatically after the completion fo that job, so `module spider` and `module load` are teh main commands you will be using. In the case that you're working on an interactive node, you will need to load these modules manually.

Some users also like to create environment scripts, for example env.sh: 

    #!/bin/bash 
    module load intel 
    module load intel-mpi
    ...

in order to load all of the things they need on the head node. Specifically, this may be helpful when you're working on compiling a program. You should keep in mind that if you'd like to load your modules in this way, you should run the script using `source env.sh`. Running it using bash, or ./, will not result in the modules being loaded inside of your current terminal session.

You should also note that each cluster has different base compiler versions, and likewise have differnet modules installed. Often times if there is a module installed on xena, but you need to use it on hopper, you can submit a ticket and have it installed for you, although this is not necessarily always the case. To create a ticket, send an email to help@carc.unm.edu.