# Amber at CARC

## Software Description

Amber is a suite of molecular simulation programs commonly used for biomolecules such as proteins, nucleic acids, and small molecules. Amber workflows usually start from topology and coordinate files prepared for a specific molecular system, then run minimization, equilibration, or production molecular dynamics. This QuickByte shows the Slurm pattern for a short MPI `pmemd` run; replace the example topology and restart filenames with files from your own prepared Amber system.

## Example Slurm Script

Save the following as `gibbs.slurm` in the example directory and submit it with `sbatch gibbs.slurm`.

```bash
#!/bin/bash -l
# Run this file with: sbatch gibbs.slurm
# This script demonstrates a two-node MPI PMEMD run.

# Give the job a recognizable scheduler name.
#SBATCH --job-name=test-amber-pmemd
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition for this short instructional example.
#SBATCH --partition=debug
# Allow enough time for the short PMEMD molecular dynamics run.
#SBATCH --time=00:10:00
# Request two nodes for distributed-memory MPI.
#SBATCH --nodes=2
# Run two MPI ranks on each node.
#SBATCH --ntasks-per-node=2
# Reserve memory for the small molecular dynamics system.
#SBATCH --mem=4G

# Fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Start from the directory where you submitted the job. This directory should
# contain system.prmtop and system.rst7, or you should edit the filenames below.
submit_dir="${SLURM_SUBMIT_DIR:-$PWD}"
topology="$submit_dir/system.prmtop"
restart="$submit_dir/system.rst7"

if [[ ! -f "$topology" || ! -f "$restart" ]]; then
    echo "Missing Amber input files." >&2
    echo "Expected: $topology" >&2
    echo "Expected: $restart" >&2
    echo "Edit the script to point at your prepared Amber topology and restart files." >&2
    exit 2
fi

# Create a clean per-job output directory so runs do not collide.
run_dir="$submit_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Reset modules and load AmberTools plus the CPU MPI PMEMD build.
module purge
module load amber/ambertools/25
module load amber/pmemd/cpu/24

# Write a short PMEMD input file.
cat > test-pmemd.in <<'EOF'
Short PMEMD example run
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

# Launch PMEMD.MPI with one rank per Slurm task.
srun -n "${SLURM_NTASKS}" pmemd.MPI -O \
    -i test-pmemd.in \
    -o prod.out \
    -p "$topology" \
    -c "$restart" \
    -r prod.rst \
    -x prod.nc

# Confirm the run reached the requested final MD step.
grep -q "NSTEP =     1000" prod.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

After the job finishes, Slurm should report a completed job with exit code `0:0`. The output directory should contain `prod.out`, `prod.rst`, and `prod.nc`. The script also checks that `prod.out` reached `NSTEP =     1000`.

```text
Slurm state: COMPLETED
Exit code: 0:0
Allocated nodes: 2
Allocated CPUs: 4
Expected files: prod.out, prod.rst, prod.nc
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and the checks in the script should pass.
