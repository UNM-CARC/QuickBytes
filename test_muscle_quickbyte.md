# MUSCLE at CARC

## Software Description

MUSCLE performs multiple sequence alignment: it takes related DNA, RNA, or protein sequences and lines them up so similarities and differences can be compared. Researchers commonly use alignments to inspect conserved regions, prepare phylogenetic analyses, or check whether related sequences contain insertions, deletions, or substitutions. This QuickByte uses a tiny synthetic FASTA file so the full workflow fits in a short debug-partition job.

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

# Fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Create a clean per-job output directory inside the submission directory.
submit_dir="${SLURM_SUBMIT_DIR:-$PWD}"
run_dir="$submit_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Load MUSCLE.
module --ignore-cache load muscle/3.8.1551-nuba

# Write a tiny FASTA file for the alignment.
cat > sequences.fa <<'EOF'
>seq1
ACGTACGTACGT
>seq2
ACGTTGGTACGT
>seq3
ACGTACGTACTT
EOF

# Run MUSCLE on the synthetic FASTA input.
muscle -in sequences.fa -out aligned.fa

# Confirm all three input sequences are represented in the alignment.
test "$(grep -c '^>' aligned.fa)" -eq 3
# Confirm a specific sequence label survived the alignment.
grep -q "seq2" aligned.fa
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

After the job finishes, Slurm should report a completed job with exit code `0:0`. The job directory under `outputs/` should contain `sequences.fa` and `aligned.fa`; the alignment file should include all three sequence headers.

```text
Slurm state: COMPLETED
Exit code: 0:0
Allocated nodes: 1
Allocated CPUs: 1
Expected files: sequences.fa, aligned.fa
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and the checks in the script should pass.
