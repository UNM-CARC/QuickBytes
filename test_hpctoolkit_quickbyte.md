# HPCToolkit at CARC

## Software Description

HPCToolkit profiles and analyzes application performance. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `hpctoolkit/multi-node/slurm-test.sh`: `pass`, job `806454`, elapsed `00:00:01`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script demonstrates a simple multi-node executable with HPCToolkit loaded.

# Slurm resources for a small multi-node MPI-style example.
#SBATCH --job-name=test-hpctoolkit
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
if [[ -f hpctoolkit/multi-node/slurm-test.sh ]]; then
    cd hpctoolkit/multi-node
elif [[ -f ../multi-node/slurm-test.sh ]]; then
    cd ../multi-node
fi

# Fundamental: load MPI and HPCToolkit.
module load intel-oneapi-mpi/2021.15.0-6pwh hpctoolkit/2024.01.1-y3f2

# Test harness: compile the tiny hello program only if needed.
if [[ ! -x ./hello ]]; then
    # Fundamental: build the example executable.
    gcc -O2 -o hello hello.c
fi

# Fundamental: launch one hello process per Slurm task.
# Test harness: /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" ./hello
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: hpctoolkit/multi-node/slurm-test.sh
Job ID: 806454
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
