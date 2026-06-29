# Seqtk at CARC

## Software Description

SeqTK is a lightweight command-line toolkit for working with FASTA and FASTQ sequence files. It can convert between formats, trim reads, sample reads, and perform other common preprocessing steps used in genomics workflows. This QuickByte uses a tiny FASTQ file and converts it to FASTA so you can see the basic Slurm pattern without needing a large sequencing dataset.

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script converts a tiny FASTQ file to FASTA with SeqTK.

# Slurm resources for this short SeqTK example.
#SBATCH --job-name=test-seqtk
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

# Load SeqTK.
module --ignore-cache load seqtk/1.4-qhos

# Write a tiny FASTQ input.
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

# Convert FASTQ to FASTA.
seqtk seq -A reads.fq > reads.fa

# Confirm both reads are present in FASTA output.
test "$(grep -c '^>' reads.fa)" -eq 2
# Confirm read1 appears as a FASTA header.
grep -q ">read1" reads.fa
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

After the job finishes, Slurm should report a completed job with exit code `0:0`. The job directory under `outputs/` should contain the original `reads.fq` file and the converted `reads.fa` file.

```text
Slurm state: COMPLETED
Exit code: 0:0
Allocated nodes: 1
Allocated CPUs: 1
Expected files: reads.fq, reads.fa
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and the checks in the script should pass.
