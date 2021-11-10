 TAU or Tuning and Analysis Utilities is a portable profiling and tracing toolkit for perforamcne analysis of parallel programs writting in Fortran, C, C++, Java and Python. 

If you would like to trace or profile performance of your program, you can start with the following commands on the Xena cluster:

```bash
[xena ~]$ module load tau-2.30.1-gcc-10.2.0-kyoim3d
```

Once the tau module has loaded, we are all set to start tracing with TAU.

```bash 
[xena ~]$ tau_cc.sh foo.c -o foo 
```

Instead of gcc foo.c -o foo replace gcc with tau_cc.sh 

```bash 
[xena ~]$ tau_cc.sh example.c -o example -fopenmp
```

If your code uses OpenMP, mention -fopenmp while compiling your program.
Then run your program normally to get profiles. Also, module load any openmpi module like "``` module load openmpi-1.10.1-gcc-4.8.5-xv45hpa```".

```bash
[xena ~]$ OMP_NUM_THREADS = 4
```

Set OMP_NUM_threads to different numbers to get different profiles

```bash
[xena ~]$ export TAU_TRACE = 1
[xena ~]$ pprof
```

After pprof command, performance analysation will be shown. 

```bash
[xena ~]$ tau_treemerge.pl
[xena ~]$ tau2slog2 tau.trc tau.edf -o tau.slog2
[xena ~]$ jumpshot tau.slog2
```

Jumpshot is used for visualizng the trace for which X11 displace is required. For X11 forwarding, refer https://github.com/UNM-CARC/QuickBytes/blob/master/X11_forwarding.md
