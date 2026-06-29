# VASP at CARC

## Software Description

VASP performs electronic-structure calculations used in materials science, chemistry, and condensed-matter physics. A VASP run typically starts from four input files in the working directory: `INCAR`, `POSCAR`, `POTCAR`, and `KPOINTS`. This QuickByte shows the Slurm pattern for launching a small parallel VASP job on Easley; use it from a directory containing your prepared VASP inputs.

## Example Slurm Script

Save the following as `vasp_easley.slurm` in the example directory and submit it with `sbatch vasp_easley.slurm`.

```bash
#!/bin/bash
# Run this file with: sbatch vasp_easley.slurm
# This script demonstrates a two-node VASP MPI run on Easley.

# Slurm resources for a larger VASP MPI example.  Thirty-two MPI ranks per
# node fits Hopper debug's 32 CPU cores per node while still running correctly
# on Easley debug nodes.
#SBATCH --job-name=test-vasp
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=32
#SBATCH --partition=debug
#SBATCH --time=1:00:00

set -euo pipefail

# Start from the directory where you submitted the job. It should contain the
# standard VASP input files.
submit_dir="${SLURM_SUBMIT_DIR:-$PWD}"
cd "$submit_dir"

for input_file in INCAR POSCAR POTCAR KPOINTS; do
    if [[ ! -f "$input_file" ]]; then
        echo "Missing required VASP input file: $input_file" >&2
        exit 2
    fi
done

# Load VASP.
module load vasp/6.4.3

# Launch VASP with one MPI rank per Slurm task using PMI2.
srun --mpi=pmi2 vasp_std
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

After the job finishes, Slurm should report a completed job with exit code `0:0`. VASP should write its usual output files in the submission directory, including files such as `OUTCAR`, `OSZICAR`, and `vasprun.xml`, depending on your input settings.

```text
Slurm state: COMPLETED
Exit code: 0:0
Allocated nodes: 2
Allocated CPUs: 128
Expected files: OUTCAR, OSZICAR, vasprun.xml
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and VASP should finish without reporting fatal errors in the Slurm output or VASP output files.
