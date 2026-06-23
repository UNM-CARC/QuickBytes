# ORCA at CARC

## Software Description

ORCA is a quantum chemistry package. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `Orca_MPI/Easley/slurm-test.sh`: `pass`, job `806432`, elapsed `00:01:49`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

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

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: Orca_MPI/Easley/slurm-test.sh
Job ID: 806432
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:01:49
Allocated nodes: 1
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
