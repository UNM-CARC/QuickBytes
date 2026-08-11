# Using CASA on Easley and Hopper

### A Bit About CASA

[CASA](https://casa.nrao.edu/) (Common Astronomy Software Applications) is the primary software for reducing radio interferometry data from telescopes such as the Jansky Very Large Array (VLA) and the Atacama Large Millimeter/submillimeter Array (ALMA).

### Getting CASA: module on Hopper, direct path on Easley

On **Hopper**, CASA is a working module — just load it:

```bash
module load casa/6.5.2
```

On **Easley**, there is currently no `casa` module at all (`module avail casa` and `module spider casa` both come back empty — not broken, just not provided there). The same CASA install is still present on disk though, so set up an alias to it instead:

```bash
CASA_DIR=/opt/local/casa/6.5.2/casa-6.5.2-26-py3.8
alias casa="$CASA_DIR/bin/casa"
alias mpicasa="$CASA_DIR/bin/mpicasa"
```

Either way, confirm you have a working `casa` before going further:

```bash
casa --version
# CASA 6.5.2.26
```

### Getting Compute Resources with Slurm

Both clusters use Slurm, not PBS — there is no `$PBS_NODEFILE`.

Easley's partitions (per `sinfo`): `general`, `bigmem`, `h100`, `l40s`, `interactive`, `debug`, `scavenger`. Hopper's: `general`, `debug`. CASA doesn't need a GPU, so `general` or `debug` (for short test runs) is the right choice on either cluster — there is no `singleGPU` partition on either, and you don't need one.

Request an interactive session to test in:

```bash
srun --partition debug --time=00:30:00 --ntasks=1 --cpus-per-task=2 --pty bash
```

Then load the module (Hopper) or set the alias (Easley) as shown above.

### Running CASA Non-Interactively

CASA scripts are plain Python. Save a script, e.g. `hello.py`:

```python
print("Hello from inside CASA")
print(2 + 2)
```

Run it with `-c`, `--nogui`, and `--log2term` (so output goes to your terminal/log instead of a GUI logger window):

```bash
casa --nologger --nogui --log2term -c hello.py
```

Tested end-to-end on both clusters (`srun --partition debug`, single task) and produces output including:

```
CASA 6.5.2.26 -- Common Astronomy Software Applications [6.5.2.26]
Hello from inside CASA
4
```

### Running MPI-Parallel CASA with `mpicasa`

CASA ships its own `mpicasa` wrapper (a thin layer over the OpenMPI build bundled with CASA) for running CASA in parallel across multiple MPI ranks/nodes. Request more than one task from Slurm and pass the rank count to `mpicasa` with `-n`:

```bash
srun --partition debug --time=00:30:00 --ntasks=2 --cpus-per-task=2 --pty bash

mpicasa -n 2 casa --nologger --nogui --log2term -c hello.py
```

Tested end-to-end on Easley across 2 tasks (Slurm placed them on two separate nodes) and each rank correctly ran the script and printed:

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

*This quickbyte was tested against `casa/6.5.2` on both Easley (direct path) and Hopper (module).*
