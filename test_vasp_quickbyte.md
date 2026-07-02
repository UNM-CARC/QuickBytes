# VASP at CARC

## Software Description

VASP performs electronic-structure calculations used in materials science, chemistry, and condensed-matter physics. A VASP run typically starts from four input files: `INCAR`, `POSCAR`, `POTCAR`, and `KPOINTS`. This QuickByte shows the Slurm pattern for launching a small parallel VASP job on Easley using a tiny NaCl example.

NOTE: You'll need to be in the `vasp6` group and have a valid VASP license to run this example and other future VASP jobs. See the `Troubleshooting` section below if you're unsure whether you have access to the software and extra steps regarding how to obtain it.

This tutorial includes three small text input files in `vasp_assets`:

- [INCAR](vasp_assets/INCAR): VASP calculation settings
- [POSCAR](vasp_assets/POSCAR): NaCl crystal structure
- [KPOINTS](vasp_assets/KPOINTS): k-point mesh

VASP `POTCAR` files are licensed pseudopotential files and are not included here. Before submitting the job, licensed VASP users should create `vasp_assets/POTCAR` for this NaCl example using the matching PAW/PBE potentials for `Na_pv` and `Cl`. See [vasp_assets/README_POTCAR.md](vasp_assets/README_POTCAR.md).

## Running the Example Slurm Script

First, log in to Easley via SSH.

`ssh user@easley.alliance.unm.edu`

Once logged into the machine, create a separate directory for this QuickByte called `example_VASP` with:

`mkdir example_VASP`

Once the directory is created, go into `example_VASP` and create a new directory called `vasp_assets`. Copy the provided `INCAR`, `POSCAR`, and `KPOINTS` files inside the `vasp_assets` directory. In addition, also add the `POTCAR` file into the `vasp_assets` directory. Use `ls` to verify that all four files are present in `vasp_assets` before continuing on with this QuickByte.

After placing the four files in the correct directory, go back to the `example_VASP` directory and use your favorite text editor to create `vasp_easley.slurm`. In this QuickByte, nano is used due to its user friendliness. Run the command below:

`nano vasp_easley.slurm`

Copy the Slurm script below into `vasp_easley.slurm` while in the text editor:

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

NOTE: In the script where it say `module load vasp/6.4.3`, you can choose to load `vasp/6.5.1`, another version of VASP that is available on the Easley cluster.

The important Slurm resource lines in the script are the `#SBATCH` directives near the top of the script. In this example, `--nodes=2` requests two compute nodes. `--ntasks-per-node=4` runs 4 MPI processes on each node, resulting in 8 MPI ranks being allocated. `--partition=debug` means the job is submitted specifically in the debug partition. `--time=00:05:00` limits the activity of the job to 5 minutes. The `module load` command loads the VASP software environment required to run the simulation. `srun` is used when the application should be launched through Slurm across allocated tasks.

After copying the script above, exit the file with `Ctrl + X`, then type `y` to save the modified buffer. If it asks for a filename to write to, just press `Enter` to write to the newly created file. Once the file is saved, submit the job to the Slurm scheduler with:

`sbatch vasp_easley.slurm`

After submitting the job, Slurm will print a message that contains a job ID. 

`Submitted batch job <jobID>`

Take note of this job ID as it will be used when checking the results of the job.

## Example output

After the job finishes, a new directory called `outputs` should appear. In the `outputs` directory, the results of each job will be contained in a directory called `test-vasp-<jobID>`. For this QuickByte, the `test-vasp-<jobID>` directory should contain the 4 input files mentioned earlier and VASP output files such as `OUTCAR`, `OSZICAR`, and `vasprun.xml`. The output files may change depending on your input settings.

In addition to these new directories, Slurm should report a completed job with exit code `0:0`. To check this, run `sacct -j <jobID>`. You should get a similar output below:

```text
JobID           JobName  Partition    Account  AllocCPUS      State ExitCode
------------ ---------- ---------- ---------- ---------- ---------- --------
<jobID>       test-vasp      debug   <acctID>          8  COMPLETED      0:0
<jobID>.batch     batch              <acctID>          4  COMPLETED      0:0
<jobID>.exte+    extern              <acctID>          8  COMPLETED      0:0
<jobID>.0      vasp_std              <acctID>          8  COMPLETED      0:0
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and VASP should finish without reporting fatal errors in the Slurm output or VASP output files.

## Troubleshooting

If VASP reports `POSCAR found : 0 types and 0 ions`, check that `vasp_assets/POSCAR` is the NaCl file from this tutorial and is not empty. The Slurm script checks this before starting VASP so the job fails early with a clearer message.

If VASP reports `LUSE_VDW needs to be set to .TRUE.`, check that the `POTCAR` was built from the PAW/PBE `Na_pv` and `Cl` potentials described above. That error usually means the copied `POTCAR` does not match this NaCl example.
 
A common issue that new UNM CARC users may experience when running this script is that they may not have the permissions required to run the VASP software. If your job fails, go into the `example_VASP` directory and check the Slurm error file by running:

`cat test-vasp-<jobID>.err`

If the `cat` command prints that you need to be in the "vasp6" group, please email `help@carc.unm.edu` mentioning that you need access to VASP and include your research lab's license number.
