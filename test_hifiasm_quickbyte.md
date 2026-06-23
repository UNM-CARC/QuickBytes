# hifiasm at CARC

## Software Description

hifiasm assembles long-read sequencing data. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `hifiasm/single-node/slurm-test.sh`: `pass_with_log_warnings`, job `806452`, elapsed `00:00:01`, CPUs `2`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script runs a tiny hifiasm assembly smoke test.

# Slurm resources for this short threaded hifiasm example.
#SBATCH --job-name=test-hifiasm
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: start from the submission directory and move into this example
# when the job was submitted from the repository root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f reads.fq && -f hifiasm/single-node/reads.fq ]]; then
    cd hifiasm/single-node
fi

# Fundamental: load hifiasm.
module load hifiasm/0.25.0

# Test harness: remove old hifiasm outputs before rerunning.
rm -f hifiasm-test*

# Test harness: print the hifiasm version in the job log.
hifiasm --version
# Fundamental: run hifiasm using the CPU count requested from Slurm.
# Test harness: /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v hifiasm -f0 --hg-size 4k -t "${SLURM_CPUS_PER_TASK}" -o hifiasm-test reads.fq
# Test harness: list generated files so users can see what hifiasm produced.
ls -lh hifiasm-test*
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: hifiasm/single-node/slurm-test.sh
Job ID: 806452
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 1
Allocated CPUs: 2
Result: pass_with_log_warnings
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
