# Open MPI at CARC

## Software Description

Open MPI provides MPI runtime support. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `openmpi/multi-node/slurm-test.sh`: `pass`, job `806469`, elapsed `00:00:01`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script builds and runs an MPI prime-sieve example with OpenMPI.

# Slurm resources for a two-node OpenMPI example.
#SBATCH --job-name=test-openmpi
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --partition=debug

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: locate this example directory when submitted from the repo root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -d ../sieve_src && -d openmpi/multi-node ]]; then
    cd openmpi/multi-node
fi

# Fundamental: load OpenMPI.
module load openmpi/4.1.7-3ilj

# Test harness: build the sieve executable only if needed.
if [[ ! -x ../sieve ]]; then
    # Fundamental: compile the MPI source.
    make -C ../sieve_src
fi

# Fundamental: launch the MPI executable with one rank per Slurm task.
# Test harness: /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" ../sieve 10000000
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: openmpi/multi-node/slurm-test.sh
Job ID: 806469
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
