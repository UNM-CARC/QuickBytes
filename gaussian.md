# Gaussian on Easley

[Gaussian](https://gaussian.com/) is a general-purpose computational chemistry package for quantum chemistry calculations — geometry optimizations, energies, vibrational frequencies, and more. This QuickByte covers loading Gaussian on Easley, running a job interactively, and submitting a multi-node batch job.

## Loading Gaussian

```bash
module load gaussian/g16
```

Loading the module automatically sets a scratch directory for you:

```text
Gaussian scratch directory (GAUSS_SCRDIR) set to /carc/scratch/users/<your_username>/
```

## Creating an Input File

Gaussian jobs are defined in a plain-text `.com` input file: a route line (the calculation to run), a title, charge/multiplicity, and a molecular geometry. You can build a molecule visually and export it to this format using [Avogadro](https://two.avogadro.cc/) (draw the molecule, then `File > Export > Molecule...` and choose "Gaussian Z-Matrix Input"), or write the geometry by hand for something simple. For example, `water.com`:

```bash
cat > water.com <<'EOF'
%chk=water.chk
%mem=4GB
%nprocshared=4
# opt B3LYP/6-31G(d)

Water molecule optimization

0 1
O    0.000000    0.000000    0.000000
H    0.000000    0.757000    0.586000
H    0.000000   -0.757000    0.586000

EOF
```

The route line (`# opt B3LYP/6-31G(d)`) tells Gaussian to run a geometry optimization (`opt`) using the B3LYP density functional with the 6-31G(d) basis set. `0 1` is the molecular charge and spin multiplicity. Note the blank line at the very end of the file — Gaussian requires it to terminate the input.

## Running Interactively

Gaussian jobs must run on a compute node, not the login node. Request one and run directly:

```bash
srun --partition debug --ntasks 1 --cpus-per-task 4 --mem 8G --pty bash
```

```bash
module load gaussian/g16
g16 water.com water.log
```

Check the result:

```bash
grep -i "normal termination" water.log
```

Expected output:
```text
 Normal termination of Gaussian 16 at Tue Jul  7 15:03:25 2026.
```

"Normal termination" is Gaussian's way of saying the job completed successfully — for this small water optimization, in about 3 seconds. If a job fails, this line is absent and the log's last several lines will contain an error description instead.

## Running Across Multiple Nodes with Linda

To scale beyond one node, Gaussian uses a helper called **Linda** to coordinate multiple copies of itself across nodes. Linda doesn't understand Slurm directly, so a batch script needs to translate Slurm's node list into a format Linda expects. `$CARC_NODEFILE` (a CARC-provided environment variable, populated once your allocation is granted) gives you that node list.

```bash
rm -f water.log water.chk
```

```bash
cat > gaussian16_linda_water.sh <<'EOF'
#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:10:00
#SBATCH --job-name=g16_water

module load gaussian/g16

# To make linda print verbose messages
export GAUSS_LFLAGS="-v"

INPUT_MOLECULE=$SLURM_SUBMIT_DIR/water.com
OUTPUT_FILE=$SLURM_SUBMIT_DIR/water.log

# Reformat the SLURM provided list of compute nodes to a format Gaussian can understand
# i.e. remove duplicates and replace newlines with commas
export GAUSS_WDEF=$(cat $CARC_NODEFILE | uniq | sed -z 's/\n/,/g;s/,$/\n/')

# Tell Linda to use as many nodes as requested by the user
export GAUSS_PDEF=$SLURM_CPUS_PER_TASK
echo "Parallelizing $GAUSS_PDEF processes across $GAUSS_WDEF nodes."

# Set the memory Gaussian variable
export GAUSS_MDEF=4GB

# Run Gaussian
g16 $INPUT_MOLECULE $OUTPUT_FILE
EOF
```

```bash
sbatch gaussian16_linda_water.sh
squeue --me
```

Once the job finishes, its Slurm output file shows Linda scheduling work across both nodes:

```text
Gaussian scratch directory (GAUSS_SCRDIR) set to /carc/scratch/users/<your_username>/
Parallelizing 4 processes across easley019,easley020 nodes.
ntsnet: using executable file /opt/local/gaussian/g16/C.01/avx2/g16/linda-exe/l302.exel
ntsnet: trying to schedule 1 worker
ntsnet: scheduled a total of 1 worker
ntsnet: starting master process on easley019
ntsnet: starting 1 worker on easley020
...
```

(The exact node names and the specific `linda-exe` executables Gaussian schedules at each stage of the calculation will differ per run — the important part is seeing a master and worker process split across your two allocated nodes.) Check `water.log` the same way as the interactive run — it should again end with "Normal termination of Gaussian 16."

## Further Reading

- Official Gaussian documentation: [gaussian.com/man](https://gaussian.com/man/)
- Keyword reference for route lines (functionals, basis sets, job types): [gaussian.com/keywords](https://gaussian.com/keywords/)
- [Avogadro](https://two.avogadro.cc/) — molecule builder that exports to Gaussian input format

*This quickbyte was validated on Easley on 7/7/2026, based on material from the CARC "Intermediate Introduction to Computing at CARC: 1 hour version with Gaussian" workshop.*
