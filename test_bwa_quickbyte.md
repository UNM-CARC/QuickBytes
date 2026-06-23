# BWA at CARC

## Software Description

BWA maps sequencing reads to a reference genome. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `bwa/single-node/slurm-test.sh`: `pass`, job `806447`, elapsed `00:00:01`, CPUs `2`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script builds a tiny BWA index and aligns synthetic reads.

# Slurm resources for this short threaded BWA example.
#SBATCH --job-name=test-bwa
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root
# or from inside bwa/single-node.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -d "$script_dir/bwa/single-node" ]]; then
    script_dir="$script_dir/bwa/single-node"
fi

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Fundamental: load BWA.
module --ignore-cache load bwa/0.7.17-zvtr

# Test harness: write a tiny reference FASTA for this self-contained test.
cat > ref.fa <<'EOF'
>chr1
ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT
EOF
# Test harness: write two tiny reads that should align to the reference.
cat > reads.fq <<'EOF'
@read1
ACGTACGTACGT
+
IIIIIIIIIIII
@read2
TACGTACGTACG
+
IIIIIIIIIIII
EOF

# Fundamental: build the BWA index.
bwa index ref.fa
# Fundamental: align reads using the CPU count requested from Slurm.
bwa mem -t "${SLURM_CPUS_PER_TASK}" ref.fa reads.fq > aln.sam
# Test check: confirm two non-header SAM records were produced.
test "$(grep -vc '^@' aln.sam)" -eq 2
# Test check: confirm read1 appears in the alignment output.
grep -q "read1" aln.sam
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: bwa/single-node/slurm-test.sh
Job ID: 806447
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 1
Allocated CPUs: 2
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
