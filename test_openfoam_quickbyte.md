# OpenFOAM at CARC

## Software Description

OpenFOAM is a computational fluid dynamics toolkit. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `OpenFoam/cavity_gcc/gcc.slurm`: `pass`, job `806430`, elapsed `00:00:07`, CPUs `2`
- `OpenFoam/cavity_intel/intel.slurm`: `pass`, job `806431`, elapsed `00:00:06`, CPUs `2`

## Example Slurm Script

Save the following as `gcc.slurm` in the example directory and submit it with `sbatch gcc.slurm`.

```bash
#!/bin/bash -l
# Run this file with: sbatch gcc.slurm
# This script demonstrates a small parallel OpenFOAM cavity-flow run.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-openfoam-gcc
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Allow enough time for meshing, decomposition, solving, and reconstruction.
#SBATCH --time=00:10:00
# Request one node for this small parallel example.
#SBATCH --nodes=1
# Request two MPI tasks; icoFoam runs once per task under srun below.
#SBATCH --ntasks=2
# Reserve memory for the small cavity mesh and solver output.
#SBATCH --mem=2G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: locate the OpenFOAM case directory when submitted from the
# repository root or from inside OpenFoam/cavity_gcc.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/OpenFoam/cavity_gcc/gcc.slurm" ]]; then
    script_dir="$script_dir/OpenFoam/cavity_gcc"
fi

# Fundamental: load the MPI runtime and OpenFOAM module used by this example.
# --ignore-cache avoids stale Lmod cache entries on shared filesystems.
module --ignore-cache load intel-oneapi-mpi/2021.15.0-6pwh openfoam-org/11-xdif

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# Test harness: remove any stale directory with the same job-derived name.
rm -rf "$run_dir"
# Test harness: create the directory for this job's copied case files.
mkdir -p "$run_dir"
# Fundamental: copy the initial conditions and solver controls into the run dir.
cp -a "$script_dir/0" "$script_dir/system" "$run_dir/"
# Fundamental: create the OpenFOAM constant directory for physical properties.
mkdir -p "$run_dir/constant"
# Fundamental: copy the original transport properties file for compatibility.
cp "$script_dir/constant/transportProperties" "$run_dir/constant/"
# Fundamental: OpenFOAM 11 expects physicalProperties, so this converts the
# legacy case file name/object while leaving the source fixture unchanged.
sed 's/object      transportProperties;/object      physicalProperties;/' \
    "$script_dir/constant/transportProperties" > "$run_dir/constant/physicalProperties"
# Fundamental: run OpenFOAM commands from the prepared case directory.
cd "$run_dir"

# Test harness: remove any stale OpenFOAM processor directories before decomposing.
rm -rf processor*
# Fundamental: generate the computational mesh.
blockMesh > log.blockMesh
# Fundamental: split the mesh into the number of subdomains configured in system/.
decomposePar > log.decomposePar
# Fundamental: launch the parallel solver with one MPI rank per Slurm task.
srun -n "${SLURM_NTASKS}" icoFoam -parallel > log.icoFoam
# Fundamental: combine per-rank results back into a single case for inspection.
reconstructPar > log.reconstructPar
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: OpenFoam/cavity_gcc/gcc.slurm
Job ID: 806430
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:07
Allocated nodes: 1
Allocated CPUs: 2
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
