# Stacks at CARC

## Software Description

Stacks analyzes RAD-seq data. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `stacks/slurm-test.sh`: `pass`, job `806488`, elapsed `00:00:01`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.sh
# This script demonstrates Stacks ustacks on synthetic RAD-like reads.

# Slurm resources for this short threaded Stacks example.
#SBATCH --job-name=test-stacks-ustacks
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=2G
#SBATCH --time=00:05:00

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/stacks/slurm-test.sh" ]]; then
    script_dir="$script_dir/stacks"
fi

# Fundamental: reset modules and load Stacks.
module purge
module load stacks/2.53-ftxb

# Test harness: create a clean per-job output directory with a Stacks output subdir.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir/stacks_out"
cd "$run_dir"

# Test harness: generate 40 identical synthetic reads for ustacks.
for i in $(seq 1 40); do
    printf '@sample_read_%03d\nACGTTGCATGTCAGTACGTAGCTAGCTAGTACGTACGTAGCTAGCTAGTACGATCG\n+\nIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII\n' "$i"
done > sample.fastq

# Fundamental: run ustacks using the CPU count requested from Slurm.
ustacks \
    -f sample.fastq \
    -o stacks_out \
    -i 1 \
    --name sample \
    -m 3 \
    -p "${SLURM_CPUS_PER_TASK}"

# Test check: confirm the expected Stacks output tables were created.
test -s stacks_out/sample.tags.tsv
test -s stacks_out/sample.snps.tsv
test -s stacks_out/sample.alleles.tsv
# Test harness: record how many output files were produced.
printf 'ustacks_outputs=%s\n' "$(find stacks_out -type f | wc -l)" > stacks-test.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: stacks/slurm-test.sh
Job ID: 806488
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 1
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
