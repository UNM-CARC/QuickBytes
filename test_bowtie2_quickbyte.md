# Bowtie2 at CARC

## Software Description

Bowtie2 is a short-read aligner for gapped alignment. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `bowtie2/single-node/slurm-test.sh`: `pass`, job `806446`, elapsed `00:00:02`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script builds a tiny Bowtie2 index and aligns test reads with threads.

# Slurm resources for this short threaded Bowtie2 example.
#SBATCH --job-name=test-bowtie2
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: start from the submission directory and move into this example
# when the job was submitted from the repository root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f reads.fq && -f bowtie2/single-node/reads.fq ]]; then
    cd bowtie2/single-node
fi

# Fundamental: load Bowtie2 and its compiler runtime dependency.
module load gcc/14.2.0-a75l bowtie2/2.5.2-hfjx

# Test harness: remove previous index/alignment files before rerunning.
rm -f test_index.*.bt2 alignment.sam

# Fundamental: build a Bowtie2 index from the small reference FASTA.
bowtie2-build test.fa test_index
# Fundamental: align reads with the same thread count requested from Slurm.
# Test harness: /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun --cpus-per-task="${SLURM_CPUS_PER_TASK}" \
    bowtie2 -x test_index -U reads.fq -p "${SLURM_CPUS_PER_TASK}" -S alignment.sam
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: bowtie2/single-node/slurm-test.sh
Job ID: 806446
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:02
Allocated nodes: 1
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
