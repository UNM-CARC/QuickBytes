# Using CASA on Easley

### A Bit About CASA

[CASA](https://casa.nrao.edu/) (Common Astronomy Software Applications) is the primary software for reducing radio interferometry data from telescopes such as the Jansky Very Large Array (VLA) and the Atacama Large Millimeter/submillimeter Array (ALMA).

### Known Issue: `module load casa` currently does not work

Running `module avail casa` on Easley (or Hopper) will show:

```
----------------------------- /opt/local/modules ------------------------------
   casa/6.5.2
```

and `module spider casa/6.5.2` even says "This module can be loaded directly." **Don't trust this** — it's a stale entry in Lmod's cached module index. Actually running `module load casa/6.5.2` fails:

```
Lmod has detected the following error: These module(s) or extension(s) exist
but cannot be loaded as requested: "casa/6.5.2"
```

and re-checking with the cache disabled (`module --ignore_cache avail casa`) confirms there is currently no live modulefile for CASA at all — only the stale cached listing. This is a real gap in CARC's module system, not something a doc edit can fix; if you hit this, let help@carc.unm.edu know the `casa/6.5.2` module needs its modulefile restored.

The good news: the actual CASA 6.5.2 software is still installed on disk and runs fine — it's just not wired up to `module load`. Use the direct path shown below until CARC fixes the module.

```bash
CASA_BIN=/opt/local/casa/6.5.2/casa-6.5.2-26-py3.8/bin/casa
```

You can confirm this path is valid at any time with:

```bash
$CASA_BIN --version
# CASA 6.5.2.26
```

### Getting Compute Resources with Slurm

Easley uses Slurm, not PBS — there is no `$PBS_NODEFILE` and no `singleGPU` partition (that partition does not exist; CASA doesn't need a GPU anyway). Easley's real partitions, per `sinfo`, are `general`, `bigmem`, `h100`, `l40s`, `interactive`, `debug`, and `scavenger`. For an ordinary CASA reduction script, request the `general` (or `debug`, for short test runs) partition — you don't need `bigmem` or a GPU partition unless your dataset specifically demands it.

Request an interactive session to test in:

```bash
srun --partition debug --time=00:30:00 --ntasks=1 --cpus-per-task=2 --pty bash
```

Set up a convenience alias once you're on the node (do this per-session, or add it to your `~/.bashrc`):

```bash
CASA_DIR=/opt/local/casa/6.5.2/casa-6.5.2-26-py3.8
alias casa="$CASA_DIR/bin/casa"
alias mpicasa="$CASA_DIR/bin/mpicasa"
```

### Running CASA Non-Interactively

CASA scripts are plain Python. Save a script, e.g. `hello.py`:

```python
print("Hello from inside CASA")
print(2 + 2)
```

Run it with `-c`, `--nogui`, and `--log2term` (so output goes to your terminal/log instead of a GUI logger window):

```bash
$CASA_DIR/bin/casa --nologger --nogui --log2term -c hello.py
```

This was tested end-to-end on Easley (`srun --partition debug`, single task) and produces output including:

```
CASA 6.5.2.26 -- Common Astronomy Software Applications [6.5.2.26]
Hello from inside CASA
4
```

### Running MPI-Parallel CASA with `mpicasa`

CASA ships its own `mpicasa` wrapper (a thin layer over the OpenMPI build bundled with CASA) for running CASA in parallel across multiple MPI ranks/nodes. Request more than one task from Slurm and pass the rank count to `mpicasa` with `-n`:

```bash
srun --partition debug --time=00:30:00 --ntasks=2 --cpus-per-task=2 --pty bash

$CASA_DIR/bin/mpicasa -n 2 $CASA_DIR/bin/casa --nologger --nogui --log2term -c hello.py
```

This was also tested end-to-end on Easley across 2 tasks (Slurm placed them on two separate nodes) and each rank correctly ran the script and printed:

```
Hello from inside CASA
4
```

**Note:** at the end of the run you'll likely see a message like:

```
mpirun has exited due to process rank 0 with PID ... exiting improperly...
```

This is expected/benign — it happens because CASA's script mode doesn't call `MPI_Finalize()` cleanly on exit, not because anything failed. As long as your script's own output appears for every rank (as it does above), the run succeeded.

### Getting Data to Work With

For real reduction work, download a dataset from the NRAO Science Data Archive at [data.nrao.edu](https://data.nrao.edu) — pick something small (a few GB) to start with. This QuickByte only demonstrates the pipeline (Slurm → CASA → your script); it does not cover calibration/imaging workflows, which are extensively documented in [NRAO's own CASA docs](https://casaguides.nrao.edu/).

*This quickbyte was tested against `casa/6.5.2` (run from its direct install path, since the module is currently broken — see above) on Easley.*
