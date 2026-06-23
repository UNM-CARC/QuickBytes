# MUSCLE at CARC

## Software Description

MUSCLE performs multiple sequence alignment. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `muscle/single-node/slurm-test.sh`: `pass`, job `806466`, elapsed `00:00:01`, CPUs `1`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script aligns three synthetic sequences with MUSCLE.

# Slurm resources for this short MUSCLE example.
#SBATCH --job-name=test-muscle
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -d "$script_dir/muscle/single-node" ]]; then
    script_dir="$script_dir/muscle/single-node"
fi

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Fundamental: load MUSCLE.
module --ignore-cache load muscle/3.8.1551-nuba

# Test harness: write a tiny FASTA file for the alignment.
cat > sequences.fa <<'EOF'
>seq1
ACGTACGTACGT
>seq2
ACGTTGGTACGT
>seq3
ACGTACGTACTT
EOF

# Fundamental: run MUSCLE on the synthetic FASTA input.
muscle -in sequences.fa -out aligned.fa
# Test check: confirm all three input sequences are represented in the alignment.
test "$(grep -c '^>' aligned.fa)" -eq 3
# Test check: confirm a specific sequence label survived the alignment.
grep -q "seq2" aligned.fa
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: muscle/single-node/slurm-test.sh
Job ID: 806466
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 1
Allocated CPUs: 1
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
