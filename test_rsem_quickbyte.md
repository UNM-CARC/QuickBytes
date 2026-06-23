# RSEM at CARC

## Software Description

RSEM estimates gene and isoform expression. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `rsem/single-node/slurm-test.sh`: `pass`, job `806483`, elapsed `00:00:01`, CPUs `2`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script builds a tiny RSEM reference.

# Slurm resources for this short RSEM example.
#SBATCH --job-name=test-rsem
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -d "$script_dir/rsem/single-node" ]]; then
    script_dir="$script_dir/rsem/single-node"
fi

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Fundamental: load RSEM.
module --ignore-cache load rsem/1.3.3-fdfy

# Test harness: write a tiny transcript FASTA.
cat > transcripts.fa <<'EOF'
>tx1
ACGTTGCAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTA
>tx2
TTGCAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTAACG
EOF

# Fundamental: prepare an RSEM reference from the transcript FASTA.
rsem-prepare-reference transcripts.fa test_reference

# Test check: confirm expected RSEM reference metadata files were created.
test -s test_reference.grp
test -s test_reference.ti
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: rsem/single-node/slurm-test.sh
Job ID: 806483
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 1
Allocated CPUs: 2
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
