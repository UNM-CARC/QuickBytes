# VASP at CARC

## Software Description

VASP performs electronic-structure calculations. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `vasp/vasp_easley.slurm`: `pass`, job `806496`, elapsed `00:00:38`, CPUs `128`
- `vasp/NaCl_charges/slurm-test.sh`: `pass`, job `806494`, elapsed `00:00:05`, CPUs `16`
- `vasp/NaCl_charges/LUKE/slurm-test.sh`: `pass`, job `806493`, elapsed `00:00:19`, CPUs `16`
- `vasp/NaCl_charges/vasp6/slurm-test.sh`: `pass`, job `806495`, elapsed `00:00:04`, CPUs `16`

## Example Slurm Script

Save the following as `vasp_easley.slurm` in the example directory and submit it with `sbatch vasp_easley.slurm`.

```bash
#!/bin/bash
# Sample Vasp Job Submission Script
# Matthew Fricke, May 20th, 2025
# Run this file with: sbatch vasp_easley.slurm
# This script demonstrates a two-node VASP MPI run on the debug partition.

# Slurm resources for a larger VASP MPI example.  Thirty-two MPI ranks per
# node fits Hopper debug's 32 CPU cores per node while still running correctly
# on Easley debug nodes.
#SBATCH --job-name=test-vasp
#SBATCH --output=vasp_sample_easley.out
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=32
#SBATCH --mail-user=yourusername@unm.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=debug
#SBATCH --time=1:00:00

# Fundamental: load VASP.
module load vasp/6.4.3
# Fundamental: launch VASP with one MPI rank per Slurm task using PMI2.
srun --mpi=pmi2 vasp_std
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: vasp/vasp_easley.slurm
Job ID: 806496
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:38
Allocated nodes: 2
Allocated CPUs: 128
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
