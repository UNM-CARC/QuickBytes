# MUSCLE at CARC

## Software Description

MUSCLE (Multiple Sequence Comparison by Log-Expectation) is a software program used in bioinformatics to perform multiple sequence alignments of DNA, RNA, and protein sequences. It lines up sequences so that similarities and differences can be compared. Researchers commonly use alignments to inspect conserved regions, prepare phylogenetic analyses, or check whether related sequences contain insertions, deletions, or substitutions. This QuickByte uses a tiny synthetic FASTA file so the full workflow fits in a short debug-partition job. 

Below is a guide on how to submit this example job to Slurm.

## Example Slurm Script

To run this example, you must be logged into your account on a CARC machine. Open a local terminal and start an ssh session on the cluster of your choice:

'ssh username@cluster.alliance.unm.edu'

Replace "username" and "cluster" with your own username and cluster of choice.

Once logged in, it's best to run the script from an example directory so that the output files do not populate your home directory. From your home directory, create a new subdirectory:

'mkdir example'

To see the contents of your current location, type 'ls'. You should now see a subdirectory called "example". Navigate into that directory:

'cd example'

In the example directory, create a text file with the script below using the text editor of your choice. Nano is a user-friendly option. Type 'nano' to open the program. Copy and paste the script below onto the page. 
Exit the program ('ctrl + X'), type 'Y' to save, and name your file 'slurm-test.sh'. After hitting enter, you should be taken back to the terminal. Submit the job to Slurm:

`sbatch slurm-test.sh`

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

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They name the file, determine where to save the output and any error messages, and they request the debug partition, a runtime of five minutes, one compute node, one task, one CPU per task, and reserve 1 gigabyte of memory for the job. The `module --ignore-cache load muscle/3.8.1551-nuba' command prepares the software environment, and `muscle -in sequences.fa -out aligned.fa` launches the MUSCLE program while specifying which file to use as input and where to save the output.

Once you've submitted the job to Slurm, you can check the status of your job:

'squeue --me'

If you see no information under the headings, that means your job has finished and you can now examine the output.

## Example output

There should be a new folder within your example directory called "outputs". Navigate into it with 'cd outputs' and view the contents with 'ls'. You should see a subdirectory called "test-muscle-jobID" ("jobID" will be the number assigned to your job). Navigate into it with 'test-muscle-jobID'. It should contain the FASTA files `sequences.fa` and `aligned.fa`; the alignment file should include all three sequence headers.

To view the efficiency of your job and to confirm a successful completion with an exit code of '0', use the command 'seff jobID':

```text
>seff jobID
Job ID: ######
Cluster: easley
User/Group: username/groupname
State: COMPLETED (exit code 0)
Cores: 1
CPU Utilized: 00:00:01
CPU Efficiency: 33.33% of 00:00:03 core-walltime
Job Wall-clock time: 00:00:03
Memory Utilized: 68.13 MB
Memory Efficiency: 6.65% of 1.00 GB (1.00 GB/node)
[user@easley test-muscle-jobID]$
```

For a successful run, the Slurm state should be `COMPLETED`and the exit code should be `0`.
