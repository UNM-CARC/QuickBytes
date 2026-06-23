# Bowtie at CARC

## Software Description

Bowtie is a short-read aligner. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `bowtie/single-node/slurm-test.sh`: `pass_with_log_warnings`, job `806445`, elapsed `00:00:02`, CPUs `1`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script builds a tiny Bowtie index and aligns test reads.

# Slurm resources for this short serial Bowtie example.
#SBATCH --job-name=test-bowtie
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:02:00
#SBATCH --mem=1G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=debug

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: start from the submission directory and move into this example
# when the job was submitted from the repository root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f reads.fq && -f bowtie/single-node/reads.fq ]]; then
    cd bowtie/single-node
fi

# Fundamental: load Bowtie.
module load bowtie/1.3.1-pi6i

# Test harness: remove previous index/alignment files before rerunning.
rm -f test_index.*.ebwt alignment.sam
# Fundamental: build a Bowtie index from the small reference FASTA.
srun bowtie-build test.fa test_index
# Fundamental: align FASTQ reads and write SAM output.
srun bowtie -q test_index reads.fq -S alignment.sam
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: bowtie/single-node/slurm-test.sh
Job ID: 806445
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:02
Allocated nodes: 1
Allocated CPUs: 1
Result: pass_with_log_warnings
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
