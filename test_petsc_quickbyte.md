# PETSc at CARC

## Software Description

PETSc provides scalable solvers for scientific computing. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `petsc/multi-node/slurm-test.sh`: `pass`, job `806477`, elapsed `00:00:02`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script compiles and runs a tiny PETSc MPI program.

# Slurm resources for a two-node PETSc example.
#SBATCH --job-name=test-petsc
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: locate this example directory when submitted from common paths.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f petsc/multi-node/slurm-test.sh ]]; then
    cd petsc/multi-node
elif [[ -f ../multi-node/slurm-test.sh ]]; then
    cd ../multi-node
fi

# Fundamental: point Intel MPI at Slurm's PMI library when needed by this stack.
export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi2.so

# Fundamental: load PETSc and the time utility module.
module load petsc/3.9.4 time

# Test harness: build the PETSc smoke executable only if needed.
if [[ ! -x ./petsc-smoke ]]; then
    # Fundamental: compile and link against PETSc using pkg-config.
    mpicc petsc-smoke.c $(pkg-config --cflags --libs PETSc) -o petsc-smoke
fi

# Fundamental: launch one PETSc MPI rank per Slurm task.
# Test harness: $(which time) uses the module-provided time command for resource logging.
$(which time) -v srun -n "${SLURM_NTASKS}" ./petsc-smoke
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: petsc/multi-node/slurm-test.sh
Job ID: 806477
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:02
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
