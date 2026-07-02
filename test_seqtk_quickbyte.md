# Seqtk at CARC

## Software Description

SeqTK is a lightweight command-line toolkit for working with FASTA and FASTQ sequence files. It can convert between formats, trim reads, sample reads, and perform other common preprocessing steps used in genomics workflows. This QuickByte uses a tiny FASTQ file and converts it to FASTA so you can see the basic Slurm pattern without needing a large sequencing dataset.

## Example Slurm Script

First, log in to easley via SSH.

`ssh user@easley.alliance.unm.edu`

Next, navigate to the directory where you would like to work by running `cd <directory name>`. If you are following along with the QuickByte and you would like to use a sepreate directory, then you can make one with `mkdir seqtk_example`, then navigate inside the directory.

Create the script in that directory. To do this we will use a text editor. You are able to use whatever editor you prefer; however, this QuickByte will use nano. Run `nano slurm-test.sh` to create the file. Then, copy the following text and paste it into the file by right-clicking in the terminal (or by using your terminal's paste shortcut).

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
The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment. The script writes a FASTQ input and converts that input into a FASTA output.

Save the file using `Ctrl + X`, then type `y` when prompted. Then, in the terminal use `sbatch slurm-test.sh` to submit the script.

## Example output

After the job finishes, Slurm should report a completed job with exit code `0:0`. To check this use `squeue` for running jobs and `sacct -j <jobid>` for completed jobs. The job ID is the number slurm assigns to job when you submit it.

The `outputs` directory within your `seqtk_example` directory will contain another directory. This directory has the original `reads.fq` file and the converted `reads.fa` file in it.

The `reads.fa` file will contain (Use `cat reads.fa` to look at the file):

```text
cat reads.fa
>read1
ACGTACGT
>read2
TTTTCCCC
```
For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and the checks in the script should pass.

```text
Slurm state: COMPLETED
Exit code: 0:0
Allocated nodes: 1
Allocated CPUs: 1
Expected files: reads.fq, reads.fa
```

*This quickbyte was verified on 6/30/2026*
