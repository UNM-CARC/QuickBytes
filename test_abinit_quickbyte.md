# ABINIT at CARC

## Software Description

ABINIT is an electronic-structure package for first-principles materials simulations. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `abinit/test/condo.slurm`: `pass`, job `806434`, elapsed `00:00:05`, CPUs `8`
- `abinit/test/debug.slurm`: `pass`, job `806435`, elapsed `00:00:08`, CPUs `8`
- `abinit/test/general.slurm`: `pass`, job `806436`, elapsed `00:00:05`, CPUs `8`

## Example Slurm Script

Save the following as `condo.slurm` in the example directory and submit it with `sbatch condo.slurm`.

```bash
#!/bin/bash -l
# Run this file with: sbatch condo.slurm
# This script demonstrates an ABINIT MPI run using Slurm task allocation.

# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Request eight total MPI tasks.
#SBATCH -n 8 # number of processors to allocate
# Allow enough time for the small ABINIT test calculation.
#SBATCH --time=00:20:00
# Send Slurm mail to the maintainer; users may remove or change this.
#SBATCH --mail-user mfricke@unm.edu
# Send mail for all job state changes; this is optional user notification.
#SBATCH --mail-type all
# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-abinit

# Fundamental: start with a clean module environment.
module purge # make sure there are no lingering loaded modules, JIC
# Fundamental: add the local module tree that contains ABINIT modules.
module use /opt/local/modules
# Fundamental: choose the CUDA build on Hopper, otherwise use the CPU ABINIT build.
case "$(hostname -s)" in
    hopper*) module load abinit/cuda/10.4.5 ;;
    *) module load abinit/10.4.5 ;;
esac
# Test harness: locate this example directory when submitted from the repo root
# or from inside abinit/.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/abinit/test/condo.slurm" ]]; then
    script_dir="$script_dir/abinit/test"
elif [[ -f "$script_dir/test/condo.slurm" ]]; then
    script_dir="$script_dir/test"
fi

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# Test harness: create the output directory.
mkdir -p "$run_dir"
# Fundamental: copy the ABINIT input file and pseudopotentials into the run dir.
cp "$script_dir"/t41.in "$script_dir"/Si_r.psp8 "$script_dir"/O.psp8 "$run_dir"/
# Fundamental: run ABINIT from the directory containing its input files.
cd "$run_dir"

# Fundamental: name the input file passed to ABINIT below.
export INPUTFILE=t41.in # XXX FIXME! XXX

# Fundamental: launch ABINIT with the number of tasks requested from Slurm.
srun -n "$SLURM_NTASKS" abinit $INPUTFILE
# Test check: confirm ABINIT reported successful completion in its output file.
grep -q "Calculation completed" t41.abo
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: abinit/test/condo.slurm
Job ID: 806434
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:05
Allocated nodes: 1
Allocated CPUs: 8
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
