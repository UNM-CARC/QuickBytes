# LAMMPS at CARC

## Software Description

LAMMPS is a molecular dynamics code. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `lammps/multi-node/slurm-test.sh`: `pass`, job `806458`, elapsed `00:00:27`, CPUs `4`
- `lammps/single-node/slurm-test.sh`: `pass`, job `806459`, elapsed `00:00:27`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script demonstrates a two-node MPI LAMMPS run.

# Slurm resources for a four-rank multi-node LAMMPS example.
#SBATCH --job-name=test-lammps
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: locate this example directory when submitted from the repo root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f in.lj && -f lammps/multi-node/in.lj ]]; then
    cd lammps/multi-node
fi

# Fundamental: load MPI, FFTW, and LAMMPS.
module load openmpi/4.1.7-3ilj fftw/3.3.10-wfyy lammps/20250722-57pz
# CARC module files record application library paths separately from the
# dynamic linker path used by batch-launched MPI ranks.
# Fundamental: expose required shared libraries to MPI-launched LAMMPS ranks.
export LD_LIBRARY_PATH="${FFTW_LIB}:${CARC_LIBRARY_PATH}:${LD_LIBRARY_PATH:-}"
# Fundamental: launch LAMMPS with one MPI rank per Slurm task.
# Test harness: /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" lmp -in in.lj
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: lammps/multi-node/slurm-test.sh
Job ID: 806458
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:27
Allocated nodes: 2
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
