# MPI Test at CARC

## Software Description

MPI Test demonstrates running a compact MPI workload under Slurm. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `mpitest/slurm/mpi_test.slurm`: `pass`, job `806464`, elapsed `00:00:02`, CPUs `4`
- `mpitest/slurm/wheelie_mpi_test.slurm`: `pass`, job `806465`, elapsed `00:00:03`, CPUs `4`

## Example Slurm Script

Save the following as `mpi_test.slurm` in the example directory and submit it with `sbatch mpi_test.slurm`.

```bash
#!/bin/bash -l
# Run this file with: sbatch mpi_test.slurm
# This script builds and runs an MPI prime-sieve example.

# Slurm resources for a two-node MPI example.
#SBATCH --job-name=test-mpitest
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --partition=debug

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: locate the mpitest directory when submitted from slurm/ or repo root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -d ../source && -f ./mpi_test.slurm ]]; then
    cd ..
elif [[ -d mpitest/source ]]; then
    cd mpitest
fi

# Fundamental: load an MPI implementation.
module load openmpi

# Test harness: build a job-ID-specific executable so simultaneous runs do not collide.
SIEVE_EXE="./sieve-${SLURM_JOB_ID}"
# Test harness: delete the temporary executable when the job exits.
trap 'rm -f "$SIEVE_EXE"' EXIT
# Fundamental: compile the MPI source code.
make -C source OUTPUT="../${SIEVE_EXE#./}"

# Fundamental: launch the MPI program with one rank per Slurm task.
# Test harness: /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" "$SIEVE_EXE" 10000000
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: mpitest/slurm/mpi_test.slurm
Job ID: 806464
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:02
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
