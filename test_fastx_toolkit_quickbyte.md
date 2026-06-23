# FASTX-Toolkit at CARC

## Software Description

FASTX-Toolkit provides command-line utilities for FASTQ/FASTA processing. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `fastx-toolkit/single-node/slurm-test.sh`: `pass`, job `806450`, elapsed `00:00:01`, CPUs `1`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script runs FASTX-Toolkit quality statistics and FASTQ-to-FASTA conversion.

# Slurm resources for this short serial FASTX-Toolkit example.
#SBATCH --job-name=test-fastx-toolkit
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

# Test harness: locate this example directory when submitted from the repo root
# or from inside fastx-toolkit/single-node.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -d "$script_dir/fastx-toolkit/single-node" ]]; then
    script_dir="$script_dir/fastx-toolkit/single-node"
fi

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Fundamental: load FASTX-Toolkit.
module --ignore-cache load fastx-toolkit/0.0.14-36g4

# Test harness: write a tiny FASTQ input file.
cat > reads.fq <<'EOF'
@read1
ACGTACGT
+
IIIIIIII
@read2
TTTTCCCC
+
HHHHHHHH
EOF

# Fundamental: compute per-base quality statistics.
fastx_quality_stats -i reads.fq -o quality.tsv
# Fundamental: convert FASTQ reads to FASTA.
fastq_to_fasta -i reads.fq -o reads.fa
# Test check: confirm both reads were converted to FASTA.
test "$(grep -c '^>' reads.fa)" -eq 2
# Test check: confirm the statistics table has its expected header.
grep -q "^column" quality.tsv
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: fastx-toolkit/single-node/slurm-test.sh
Job ID: 806450
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 1
Allocated CPUs: 1
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
