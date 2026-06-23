# Amber at CARC

## Software Description

Amber provides molecular simulation tools for biomolecules. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `amber/gibbs.slurm`: `pass`, job `806440`, elapsed `00:03:02`, CPUs `4`
- `amber/pmemd/cuda/slurm-test.sh`: `pass`, job `806441`, elapsed `00:00:10`, CPUs `1`
- `amber/pmemd/muti-node/slurm-test.sh`: `pass`, job `806442`, elapsed `00:03:09`, CPUs `4`
- `amber/pmemd/single-node/slurm-test.sh`: `pass`, job `806443`, elapsed `00:02:59`, CPUs `4`
- `amber/ambertools/muti-node/slurm-test.sh`: `pass`, job `806438`, elapsed `00:00:04`, CPUs `4`
- `amber/ambertools/single-node/slurm-test.sh`: `pass`, job `806439`, elapsed `00:00:02`, CPUs `1`

## Example Slurm Script

Save the following as `gibbs.slurm` in the example directory and submit it with `sbatch gibbs.slurm`.

```bash
#!/bin/bash -l
# Run this file with: sbatch gibbs.slurm
# This script demonstrates a two-node MPI PMEMD run.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-amber-pmemd
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Allow enough time for the short PMEMD molecular dynamics run.
#SBATCH --time=00:10:00
# Request two nodes for distributed-memory MPI.
#SBATCH --nodes=2
# Run two MPI ranks on each node.
#SBATCH --ntasks-per-node=2
# Reserve memory for the small molecular dynamics system.
#SBATCH --mem=4G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: locate the Amber directory when submitted from the repo root or
# from inside amber/.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/amber/gibbs.slurm" ]]; then
    script_dir="$script_dir/amber"
fi

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# Test harness: remove any stale directory with the same job-derived name.
rm -rf "$run_dir"
# Test harness: create the output directory.
mkdir -p "$run_dir"
# Fundamental: run PMEMD from the per-job directory so outputs stay contained.
cd "$run_dir"

# Fundamental: reset modules and load AmberTools plus the CPU MPI PMEMD build.
module purge
module load amber/ambertools/25
module load amber/pmemd/cpu/24

# Test harness: write a short PMEMD input file for the regression run.
cat > test-pmemd.in <<'EOF'
TX Motif short PMEMD regression run
 &cntrl
  imin=0, irest=1, ntx=5,
  ntb=2, iwrap=1, pres0=1.0, ntp=1, taup=2.0,
  cut=12.0, ntr=0, ntc=2, ntf=2,
  tempi=300.0, temp0=300.0, ntt=3, gamma_ln=5.0, ig=-1,
  nstlim=1000, dt=0.002,
  ntpr=500, ntwx=1000, ntwr=1000,
  ioutfm=0
 /
EOF

# Fundamental: launch PMEMD.MPI with one rank per Slurm task.
srun -n "${SLURM_NTASKS}" pmemd.MPI -O \
    -i test-pmemd.in \
    -o prod.out \
    -p "$script_dir/data/TXM-wbions.prmtop" \
    -c "$script_dir/data/TXM-wbions-prod5-r1.rst" \
    -r prod.rst \
    -x prod.nc

# Test check: confirm the run reached the requested final MD step.
grep -q "NSTEP =     1000" prod.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: amber/gibbs.slurm
Job ID: 806440
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:03:02
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
