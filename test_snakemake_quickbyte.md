# Snakemake at CARC

## Software Description

Snakemake is a workflow engine. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `snakemake/slurm-test.sh`: `pass`, job `806486`, elapsed `00:00:02`, CPUs `2`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script demonstrates a small local Snakemake workflow inside a Slurm job.

# Slurm resources for this small workflow example.
#SBATCH --job-name=test-snakemake
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/snakemake/slurm-test.sh" ]]; then
    script_dir="$script_dir/snakemake"
fi

# Test harness: create a clean per-job output directory and copy workflow inputs.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cp -a "$script_dir/Snakefile" "$script_dir/code" "$script_dir/data" "$run_dir/"
cd "$run_dir"

# Fundamental: load Snakemake and Python.
module --ignore-cache load snakemake/6.15.1-6ocs python/3.13.5-ajzf

# Fundamental: run Snakemake locally using the CPU count requested from Slurm.
snakemake --cores "${SLURM_CPUS_PER_TASK}" --printshellcmds results/results_all.txt
# Test check: confirm the workflow produced its final output file.
test -s results/results_all.txt
# Test check: confirm the output has one result per input step size.
test "$(wc -l < results/results_all.txt)" -eq "$(wc -l < data/step_sizes.txt)"
# Test check: confirm the results file contains pi estimates.
grep -q "pi =" results/results_all.txt
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: snakemake/slurm-test.sh
Job ID: 806486
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:02
Allocated nodes: 1
Allocated CPUs: 2
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
