# VASP at CARC

## Software Description

VASP performs electronic-structure calculations used in materials science, chemistry, and condensed-matter physics. A VASP run typically starts from four input files: `INCAR`, `POSCAR`, `POTCAR`, and `KPOINTS`. This QuickByte shows the Slurm pattern for launching a small parallel VASP job on Easley using a tiny NaCl example.

This tutorial includes three small text input files in `vasp_assets`:

- [INCAR](vasp_assets/INCAR): VASP calculation settings
- [POSCAR](vasp_assets/POSCAR): NaCl crystal structure
- [KPOINTS](vasp_assets/KPOINTS): k-point mesh

VASP `POTCAR` files are licensed pseudopotential files and are not included here. Before submitting the job, licensed VASP users should create `vasp_assets/POTCAR` for this NaCl example using the matching PAW/PBE potentials for `Na_pv` and `Cl`. See [vasp_assets/README_POTCAR.md](vasp_assets/README_POTCAR.md).

## Example Slurm Script

Save the following as `vasp_easley.slurm` in the same directory as `vasp_assets`, then submit it with `sbatch vasp_easley.slurm`.

```bash
#!/bin/bash
# Run this file with: sbatch vasp_easley.slurm
# This script demonstrates a small multi-node VASP MPI run on Easley.

# Slurm resources for a short two-node VASP MPI smoke test.
#SBATCH --job-name=test-vasp
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:05:00

set -euo pipefail

# Start from the directory where you submitted the job. It should contain the
# vasp_assets directory.
submit_dir="${SLURM_SUBMIT_DIR:-$PWD}"
asset_dir="$submit_dir/vasp_assets"

for input_file in INCAR POSCAR POTCAR KPOINTS; do
    if [[ ! -f "$asset_dir/$input_file" ]]; then
        echo "Missing required VASP input file: $asset_dir/$input_file" >&2
        if [[ "$input_file" == "POTCAR" ]]; then
            echo "POTCAR files are licensed. Create vasp_assets/POTCAR from your licensed VASP pseudopotentials." >&2
        fi
        exit 2
    fi
done

for input_file in INCAR POSCAR POTCAR KPOINTS; do
    if [[ ! -s "$asset_dir/$input_file" ]]; then
        echo "Required VASP input file is empty: $asset_dir/$input_file" >&2
        exit 2
    fi
done

if ! awk 'NR == 6 { exit !($1 == "Na" && $2 == "Cl") }' "$asset_dir/POSCAR"; then
    echo "POSCAR should list Na and Cl as the element names on line 6." >&2
    exit 2
fi

if ! awk 'NR == 7 { exit !($1 == 1 && $2 == 1) }' "$asset_dir/POSCAR"; then
    echo "POSCAR should list one Na atom and one Cl atom on line 7." >&2
    exit 2
fi

if ! grep -q "PAW_PBE Na_pv" "$asset_dir/POTCAR" || ! grep -q "PAW_PBE Cl" "$asset_dir/POTCAR"; then
    echo "POTCAR should contain the PAW/PBE Na_pv and Cl potentials for this example." >&2
    exit 2
fi

# Create a clean per-job output directory inside the submission directory.
run_dir="$submit_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Copy the VASP input files into the run directory so outputs stay together.
cp "$asset_dir"/INCAR .
cp "$asset_dir"/POSCAR .
cp "$asset_dir"/POTCAR .
cp "$asset_dir"/KPOINTS .

# Load VASP.
module purge
module load vasp/6.4.3

# Launch VASP with one MPI rank per Slurm task using PMI2.
srun --mpi=pmi2 vasp_std > vasp.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

After the job finishes, Slurm should report a completed job with exit code `0:0`. The output directory under `outputs/` should contain the copied input files and VASP output files such as `OUTCAR`, `OSZICAR`, and `vasprun.xml`, depending on your input settings.

```text
Slurm state: COMPLETED
Exit code: 0:0
Allocated nodes: 2
Allocated CPUs: 8
Expected files: OUTCAR, OSZICAR, vasprun.xml
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and VASP should finish without reporting fatal errors in the Slurm output or VASP output files.

## Troubleshooting

If VASP reports `POSCAR found : 0 types and 0 ions`, check that `vasp_assets/POSCAR` is the NaCl file from this tutorial and is not empty. The Slurm script checks this before starting VASP so the job fails early with a clearer message.

If VASP reports `LUSE_VDW needs to be set to .TRUE.`, check that the `POTCAR` was built from the PAW/PBE `Na_pv` and `Cl` potentials described above. That error usually means the copied `POTCAR` does not match this NaCl example.
