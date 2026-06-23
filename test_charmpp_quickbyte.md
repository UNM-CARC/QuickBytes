# Charm++ at CARC

## Software Description

Charm++ is a parallel programming system. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `charm++/multi-node/slurm-test.sh`: `pass`, job `806448`, elapsed `00:00:04`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script demonstrates a multi-node Charm++ program.

# Slurm resources for a two-node Charm++ example.
#SBATCH --job-name=test-charm++
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
if [[ -f charm++/multi-node/slurm-test.sh ]]; then
    cd charm++/multi-node
elif [[ -f ../multi-node/slurm-test.sh ]]; then
    cd ../multi-node
fi

# Fundamental: load Charm++ and the time utility module.
module load charmpp time

# Test harness: build the example hello program only if it is not already built.
if [[ ! -x ./hello ]]; then
    # Fundamental: enter the source directory before compiling.
    cd hello_example/
    # Fundamental: generate Charm++ interface code from hello.ci.
    charmc hello.ci
    # Fundamental: compile the Charm++ C++ source into an executable.
    charmc hello.C -o hello
    # Test harness: move the executable next to this Slurm script.
    mv hello ../
    # Test harness: return to the Slurm example directory.
    cd ../
fi

# Fundamental: convert Slurm's node list into the machine-file format charmrun expects.
scontrol show hostnames $SLURM_JOB_NODELIST | awk '{print "host "$1}' > nodelist.txt

# Fundamental: launch the Charm++ program with one processing element per Slurm task.
# Test harness: $(which time) uses the module-provided time command for resource logging.
$(which time) -v charmrun "+p${SLURM_NTASKS}" ./hello ++nodelist nodelist.txt ++remote-shell ssh
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: charm++/multi-node/slurm-test.sh
Job ID: 806448
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:04
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
