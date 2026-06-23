# MolecularDynamics2 at CARC

## Software Description

The MolecularDynamics2 examples demonstrate submitting NAMD-style molecular dynamics workloads through Slurm. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `MolecularDynamics2/kf5_longOct2.slurm`: `pass`, job `806427`, elapsed `00:00:31`, CPUs `8`
- `MolecularDynamics2/kf5_trial_01.slurm`: `pass`, job `806428`, elapsed `00:00:31`, CPUs `8`
- `MolecularDynamics2/calc_pi_parallel.slurm`: `pass_with_log_warnings`, job `806426`, elapsed `00:00:01`, CPUs `8`

## Example Slurm Script

Save the following as `kf5_longOct2.slurm` in the example directory and submit it with `sbatch kf5_longOct2.slurm`.

```bash
#!/bin/bash -l
# Run this file with: sbatch kf5_longOct2.slurm
# This script demonstrates a single-node multicore NAMD run.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-namd-long
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Allow enough time for the short NAMD example to finish.
#SBATCH --time=00:10:00
# Request one node for this shared-memory NAMD run.
#SBATCH --nodes=1
# Request one Slurm task; NAMD will use threads inside this task.
#SBATCH --ntasks=1
# Reserve eight CPU cores for NAMD's +p option below.
#SBATCH --cpus-per-task=8
# Reserve memory for the small ubiquitin-water test system.
#SBATCH --mem=4G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate the repository root whether sbatch was run from the
# repository root or from the MolecularDynamics2 directory.
root_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$root_dir/MolecularDynamics2/kf5_longOct2.slurm" ]]; then
    root_dir="$root_dir"
elif [[ -f "$PWD/kf5_longOct2.slurm" ]]; then
    root_dir="$(cd "$PWD/.." && pwd)"
fi

# Fundamental input location: reuse the tested NAMD single-node fixture files.
fixture_dir="$root_dir/namd/single-node"
# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$root_dir/MolecularDynamics2/TMD/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# Test harness: remove any stale directory with the same job-derived name.
rm -rf "$run_dir"
# Test harness: create the directory that will hold this job's copied inputs.
mkdir -p "$run_dir"
# Fundamental: copy the NAMD configuration, structure, topology, and parameters
# into the per-job directory before running the calculation.
cp "$fixture_dir"/ubq_ws_eq.conf \
   "$fixture_dir"/ubq_ws.pdb \
   "$fixture_dir"/ubq_ws.psf \
   "$fixture_dir"/par_all27_prot_lipid.inp \
   "$run_dir"/
# Fundamental: run NAMD from the directory containing the copied input files.
cd "$run_dir"

# Fundamental: load the multicore NAMD module.
module load namd/3.0/multicore

# Fundamental: run NAMD with the same number of worker threads requested from Slurm.
namd3 +p"${SLURM_CPUS_PER_TASK}" ubq_ws_eq.conf > try01.log
# Test check: confirm NAMD reached timing output, which indicates real execution.
grep -q "TIMING: " try01.log
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: MolecularDynamics2/kf5_longOct2.slurm
Job ID: 806427
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:31
Allocated nodes: 1
Allocated CPUs: 8
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
