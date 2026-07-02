# Amber at CARC

## Software Description

Amber (Assisted Model Building with Energy Refinement) is a suite of molecular simulation programs used to carry out simulations on biomolecules such as proteins, nucleic acids, and other small molecules for research purposes including drug discovery, molecular interactions, and refining protein structure. There are two related packages designed to work together: AmberTools and Amber. AmberTools is a collection of free and open-source programs used to prepare molecular systems (LEaP, Antechamber), analyze the results (cpptraj, MMPBSA.py) and run simulations using 'sander', an MD (molecular dynamics) engine included for free with AmberTools. Amber is a commercial package which provides 'pmemd', a faster, more optimized MD engine.

This QuickByte runs a small AmberTools minimization with `sander`, which is a good first test that Amber is loading correctly and that Slurm is launching the job in the expected working directory.


## Example Slurm Script

To run this example, you must be logged into your account on a CARC machine. Open a local terminal and start an ssh session on the cluster of your choice:

'ssh username@cluster.alliance.unm.edu'

Replace "username" and "cluster" with your own username and cluster of choice.

Once logged in, navigate to your working directory, which is the directory where you will save your Slurm script and where you want any output files to populate. If you need to create an example working directory, while in your home directory, create a new subdirectory:

'mkdir Amber example'

To see the contents of your current location, type 'ls'. You should now see a subdirectory called "Amber example". Navigate into that directory:

'cd Amber example'

This tutorial includes a tiny prepared example system, and the files below will be used in the minimization with 'sander'. In the Amber example directory, create an `amber_assets` subdirectory:

'mkdir amber_assets'

 Download the three files below into the 'amber_assets' directory:

- [test.prmtop](amber_assets/test.prmtop): Amber topology file
- [min.rst](amber_assets/min.rst): starting coordinates
- [min.in](amber_assets/min.in): minimization control file

In the Amber example directory, create a text file with the script below using the text editor of your choice. Nano is a user-friendly option. Type 'nano' to open the program. Copy and paste the script below onto the page. 
Exit the program ('ctrl + X'), type 'Y' to save, and name your file 'slurm-test.sh'. After hitting enter, you should be taken back to the terminal. Submit the job to Slurm:
 
 `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script runs a short AmberTools minimization with sander.

# Slurm resources for this small single-node AmberTools example.
#SBATCH --job-name=test-ambertools
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G

# Fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Start from the directory where you submitted the job.
submit_dir="${SLURM_SUBMIT_DIR:-$PWD}"
asset_dir="$submit_dir/amber_assets"

for input_file in test.prmtop min.rst min.in; do
    if [[ ! -f "$asset_dir/$input_file" ]]; then
        echo "Missing required input file: $asset_dir/$input_file" >&2
        echo "Download the Amber example files into amber_assets before submitting." >&2
        exit 2
    fi
done

# Create a clean per-job output directory inside the submission directory.
run_dir="$submit_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Copy the input files into the run directory so outputs stay together.
cp "$asset_dir"/test.prmtop .
cp "$asset_dir"/min.rst .
cp "$asset_dir"/min.in .

# Load AmberTools.
module purge
module load amber/ambertools/25

# Run a short minimization with sander.
sander -O \
    -i min.in \
    -o min.out \
    -p test.prmtop \
    -c min.rst \
    -r minimized.rst

# Confirm that sander completed and wrote the expected restart file.
grep -q "FINAL RESULTS" min.out
test -s minimized.rst
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They name the file, determine where to save the output and any error messages, and they request the debug partition, a runtime of five minutes, one compute node, one task, one CPU per task, and reserve 2 gigabytes of memory for the job. The `module load` command prepares the AmberTools environment.

Once you've submitted the job to Slurm, you will see your Job ID. You can check the status of your job:

'squeue --me'

If you see no information under the headings, that means your job has finished and you can now examine the output.


## Example output

After the job finishes, the newly created output directory under `outputs` should contain the copied input files plus `min.out` and `minimized.rst`.

Slurm should report a completed job with exit code `0:0`. Check by typing either 'sacct -j JobID' (Slurm Accounting command) or 'seff JobID' (Slurm Job Efficiency Report). Below is an example of 'sacct -j 853939':

```text
JobID           JobName  Partition    Account  AllocCPUS      State ExitCode
------------ ---------- ---------- ---------- ---------- ---------- --------
853939       test-ambe+      debug    2016553          1  COMPLETED      0:0
853939.batch      batch               2016553          1  COMPLETED      0:0
853939.exte+     extern               2016553          1  COMPLETED      0:0

```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be 0, `min.out` should contain `FINAL RESULTS`, and `minimized.rst` should be non-empty.
