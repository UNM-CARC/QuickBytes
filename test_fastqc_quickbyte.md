# FastQC at CARC

## Software Description

FastQC reports quality-control metrics for sequencing reads. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `fastqc/single-node/slurm-test.sh`: `pass`, job `806449`, elapsed `00:00:04`, CPUs `2`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script runs FastQC on a tiny FASTQ file.

# Slurm resources for this short threaded FastQC example.
#SBATCH --job-name=test-fastqc
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
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
if [[ ! -f reads.fq && -f fastqc/single-node/reads.fq ]]; then
    cd fastqc/single-node
fi

# Fundamental: load FastQC.
module load fastqc/0.12.1-yy7t

# Test harness: remove prior FastQC output before rerunning.
rm -f reads_fastqc.html reads_fastqc.zip
# Fundamental: run FastQC using the thread count requested from Slurm.
# Test harness: /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun --cpus-per-task="${SLURM_CPUS_PER_TASK}" \
    fastqc --threads "${SLURM_CPUS_PER_TASK}" reads.fq
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: fastqc/single-node/slurm-test.sh
Job ID: 806449
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:04
Allocated nodes: 1
Allocated CPUs: 2
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
