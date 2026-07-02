# ORCA at CARC

## Software Description

This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the debug partition and serve as a starting point for adapting the application to a real research workload.

ORCA is an ab initio quantum chemistry package. Ab initio quantum chemistry is a computational approach that calculates molecular properties and electronic structures using fundamental physics laws or first principles. ORCA’s applications include large molecules, transition metal complexities and their spectroscopic properties. ORCA was developed by Frank Neese’s research group. 

## Example Slurm Script

First, log in to easley via SSH.

`ssh user@easley.alliance.unm.edu`

Next, navigate to the directory where you would like to work by running `cd <directory name>`. If you are following along with the QuickByte and you would like to use a separate directory, then you can make one with `mkdir orca_example`, then navigate inside the directory.

Create the script in that directory. To do this we will use a text editor. You are able to use whatever editor you prefer; however, this QuickByte will use nano. Run `nano slurm-test.sh` to create the file. Then, copy the following text and paste it into the file by right-clicking in the terminal (or by using your terminal's paste shortcut).

```bash
#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.sh
# This script demonstrates an ORCA parallel quantum chemistry calculation.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-orca
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Request one node for this small parallel ORCA calculation.
#SBATCH --nodes=1
# Request four MPI ranks; the ORCA %pal block below uses this value.
#SBATCH --ntasks=4
# Use one CPU core per MPI rank.
#SBATCH --cpus-per-task=1
# Reserve memory for ORCA and the caffeine test calculation.
#SBATCH --mem=8G
# Keep this smoke test short.
#SBATCH --time=00:05:00

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this ORCA example directory when submitted from the
# repository root or from inside Orca_MPI/Easley.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/Orca_MPI/Easley/slurm-test.sh" ]]; then
    script_dir="$script_dir/Orca_MPI/Easley"
fi

# Fundamental: reset modules and load the tested ORCA version.
module purge
module load orca/6.1.1

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# Test harness: remove any stale directory with the same job-derived name.
rm -rf "$run_dir"
# Test harness: create the directory where this job will write files.
mkdir -p "$run_dir"
# Fundamental: run ORCA from the per-job directory so outputs stay contained.
cd "$run_dir"

# Test harness: write a small ORCA input file. The %pal nprocs line uses
# SLURM_NTASKS so the chemistry input matches the resources requested above.
cat > caffeine-parallel.inp <<EOF
! B3LYP def2-TZVP def2/J RIJCOSX TightSCF

%pal
  nprocs ${SLURM_NTASKS}
end

%maxcore 1500

* xyz 0 1
C          -0.89719        -0.14526        -0.01712
C          -0.31801         1.12052        -0.01605
N           1.02504         1.25819        -0.01068
C           1.78461         0.13754        -0.00340
O           2.98561         0.25331         0.01541
N           1.24135        -1.10509        -0.01035
C          -0.09959        -1.29101        -0.01466
O          -0.58644        -2.39340        -0.00752
N          -2.23565         0.02288        -0.00379
N          -1.29887         2.05099        -0.00104
C          -2.46211         1.35706         0.00590
C          -3.24554        -1.04475         0.01817
C           1.64933         2.58910         0.00651
C           2.12014        -2.28471         0.01048
H          -3.45128         1.81516         0.02537
H          -4.24346        -0.60797         0.05962
H          -3.15205        -1.64982        -0.88483
H          -3.08816        -1.67505         0.89347
H           2.04193         2.79132         1.00292
H           0.91133         3.34819        -0.25231
H           2.46435         2.61818        -0.71618
H           1.71573        -3.05255        -0.64840
H           3.11940        -2.01254        -0.32771
H           2.17598        -2.67402         1.02712
*
EOF

# ORCA's MPI-enabled runs require invoking the full executable path.
# Fundamental: command -v records the absolute ORCA executable path from the module.
orca_bin="$(command -v orca)"
# Fundamental: run ORCA on the generated caffeine input file.
"$orca_bin" caffeine-parallel.inp > caffeine-parallel.out

# Test check: confirm ORCA reached normal termination.
grep -q "ORCA TERMINATED NORMALLY" caffeine-parallel.out
# Test check: confirm ORCA computed an energy, not just parsed the input.
grep -q "FINAL SINGLE POINT ENERGY" caffeine-parallel.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The script unloads all modules and uses the `module load` command to prepare the ORCA software environment (version 6.1.1) needed for running the calculation. In addition, it also sets up a caffeine input file that is used for running ORCA.

After copying the script above, exit the file with `Ctrl + X`, then type `y` to save the modified buffer. If it asks for a filename to write to, just press `Enter` to write to the newly created file. Once the file is saved, submit the job to the Slurm scheduler with:

`sbatch slurm-test.sh`

## Example output

Once you've submitted the job to Slurm, you will see your Job ID. You can check the status of your job:

`squeue --me`

Alternatively, you can watch the progress of your job:

`watch squeue --me`

If you see no information under the headings, that means your job has finished and you can now examine the output. After the job finishes, the newly created directory under `outputs` should contain your files.

Slurm should report a completed job with exit code `0:0`. Check by typing either `sacct -j <JobID>` (Slurm Accounting command) or `seff <JobID>` (Slurm Job Efficiency Report). Below is an example of `sacct -j 861338`:

```text
sacct -j 861338
JobID           JobName  Partition    Account  AllocCPUS      State ExitCode
------------ ---------- ---------- ---------- ---------- ---------- --------
861338        test-orca      debug    2016553          4  COMPLETED      0:0
861338.batch      batch               2016553          4  COMPLETED      0:0
861338.exte+     extern               2016553          4  COMPLETED      0:0
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.

*This QuickByte was validated 7/2/2026*
