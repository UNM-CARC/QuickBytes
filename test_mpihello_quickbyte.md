# MPI Hello at CARC

## Software Description

MPI Hello is a minimal MPI test program for checking rank launch across Slurm allocations. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `mpihello/mpihello.slurm`: `pass`, job `806463`, elapsed `00:00:02`, CPUs `4`

## Example Slurm Script

Save the following as `mpihello.slurm` in the example directory and submit it with `sbatch mpihello.slurm`.

```bash
#!/bin/bash -l
# Run this file with: sbatch mpihello.slurm
# This script compiles and runs a tiny MPI hello-world program.

# Slurm resources for a two-node MPI example.
#SBATCH --job-name=test-mpihello
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --mem=1G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Fundamental: run from the directory where sbatch was submitted.
cd "${SLURM_SUBMIT_DIR:-$PWD}"

# Fundamental: load OpenMPI compiler wrappers and runtime.
module load openmpi/4.1.7-3ilj

# Fundamental: compile the MPI C++ example.
mpicxx mpihello.cpp -o mpihello
# Fundamental: launch one MPI rank per Slurm task.
srun -n "${SLURM_NTASKS}" ./mpihello
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: mpihello/mpihello.slurm
Job ID: 806463
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:02
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
