# Amber at CARC

## Software Description

Amber is a suite of molecular simulation programs used to study biomolecules such as proteins, nucleic acids, and small molecules. Researchers use Amber to prepare molecular systems, minimize structures, equilibrate simulations, and run molecular dynamics. This QuickByte runs a small AmberTools minimization with `sander`, which is a good first test that Amber is loading correctly and that Slurm is launching the job in the expected working directory.

This tutorial includes a tiny prepared example system. Download these files into an `amber_assets` directory next to your Slurm script:

- [test.prmtop](amber_assets/test.prmtop): Amber topology file
- [min.rst](amber_assets/min.rst): starting coordinates
- [min.in](amber_assets/min.in): minimization control file

## Example Slurm Script

Save the following as `slurm-test.sh` in the same directory as `amber_assets`, then submit it with `sbatch slurm-test.sh`.

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

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a short amount of time, one CPU task, and enough memory for this small minimization. The `module load` command prepares the AmberTools environment.

## Example output

After the job finishes, Slurm should report a completed job with exit code `0:0`. The output directory under `outputs/` should contain the copied input files plus `min.out` and `minimized.rst`.

```text
Slurm state: COMPLETED
Exit code: 0:0
Allocated nodes: 1
Allocated CPUs: 1
Expected files: min.out, minimized.rst
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, `min.out` should contain `FINAL RESULTS`, and `minimized.rst` should be non-empty.
