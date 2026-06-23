# UPC++ at CARC

## Software Description

UPC++ is a C++ library for asynchronous partitioned global address space programming. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `upcxx/multi-node/slurm-test.sh`: `pass`, job `806491`, elapsed `00:00:03`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script demonstrates a multi-node UPC++ hello-world build and run.

# Slurm resources for a two-node UPC++ example.
#SBATCH --job-name=test-upcxx
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=8G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: locate this example directory when submitted from common paths.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f upcxx/multi-node/slurm-test.sh ]]; then
    cd upcxx/multi-node
elif [[ -f ../multi-node/slurm-test.sh ]]; then
    cd ../multi-node
fi

# Fundamental: load the UPC++ module appropriate for the current cluster.
case "$(hostname -s)" in
    hopper*)
        module load upcxx/2022.3.0-yrwd
        ;;
    *)
        module load openmpi/4.1.7-e7k3 upcxx/2023.9.0-27k4
        ;;
esac

# Test harness: remove stale build products.
make clean
# Fundamental: build the UPC++ hello program.
make

# Fundamental: launch one UPC++ process per Slurm task.
# Test harness: /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" ./hello
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: upcxx/multi-node/slurm-test.sh
Job ID: 806491
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:03
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
