# Picard at CARC

## Software Description

Picard provides tools for manipulating sequencing files. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `picard/single-node/slurm-test.sh`: `pass`, job `806478`, elapsed `00:00:03`, CPUs `1`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script creates a Picard sequence dictionary for a tiny reference.

# Slurm resources for this short Picard example.
#SBATCH --job-name=test-picard
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -d "$script_dir/picard/single-node" ]]; then
    script_dir="$script_dir/picard/single-node"
fi

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Fundamental: load Picard.
module --ignore-cache load picard/3.1.1-lsaf

# Test harness: write a tiny reference FASTA.
cat > reference.fa <<'EOF'
>chr1
ACGTTGCAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTA
EOF

# Fundamental: create a Picard sequence dictionary.
picard CreateSequenceDictionary \
    R=reference.fa \
    O=reference.dict

# Test check: confirm the dictionary contains the expected contig.
grep -q "SN:chr1" reference.dict
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: picard/single-node/slurm-test.sh
Job ID: 806478
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:03
Allocated nodes: 1
Allocated CPUs: 1
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
