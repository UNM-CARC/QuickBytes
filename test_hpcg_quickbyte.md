# HPCG at CARC

## Software Description

HPCG is a benchmark for sparse linear algebra performance. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `hpcg/multi-node/slurm-test.sh`: `pass`, job `806453`, elapsed `00:00:12`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script demonstrates running HPCG across two nodes.

# Slurm resources for a small multi-node HPCG benchmark.
#SBATCH --job-name=test-hpcg
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: locate this example directory when submitted from the repo root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f hpcg.dat && -f hpcg/multi-node/hpcg.dat ]]; then
    cd hpcg/multi-node
fi

# Fundamental: load MPI and HPCG.
module load openmpi/4.1.7-3ilj hpcg/3.1-hchi
# Fundamental: launch one HPCG rank per Slurm task.
# Test harness: /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" xhpcg
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: hpcg/multi-node/slurm-test.sh
Job ID: 806453
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:12
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
