# Nextflow at CARC

## Software Description

Nextflow is a workflow manager for reproducible pipelines. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `Nextflow/slurm-test.sh`: `pass`, job `806429`, elapsed `00:00:21`, CPUs `32`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script demonstrates launching a Nextflow workflow inside a Slurm job.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-nextflow
# Write standard output to a Slurm job-ID-specific file.
#SBATCH --output slurm-%j.out
# Write standard error to a Slurm job-ID-specific file.
#SBATCH --error slurm-%j.error
# Allow enough time for the workflow smoke test.
#SBATCH --time 00:20:00
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Request one scheduler task; Nextflow coordinates work from this process.
#SBATCH --ntasks=1
# Reserve a small number of CPU cores that the local workflow can use.
#SBATCH --cpus-per-task=4
# Reserve memory for the workflow and its local tasks.
#SBATCH --mem=32G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: start from the directory where sbatch was submitted.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
# Test harness: locate the Nextflow example if submitted from the repo root or
# from inside the Nextflow directory.
if [[ -f ../Nextflow/slurm-test.sh ]]; then
    cd ../Nextflow
elif [[ -f Nextflow/slurm-test.sh ]]; then
    cd Nextflow
fi

# Fundamental: load Java and Nextflow; GCC is included for toolchain compatibility.
module load gcc openjdk nextflow/24.10.5-iysd

# Fundamental: run the workflow with its local configuration and write outputs
# under results so users can inspect what the workflow produced.
nextflow run main.nf -c ./nextflow.config --outdir results
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: Nextflow/slurm-test.sh
Job ID: 806429
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:21
Allocated nodes: 1
Allocated CPUs: 32
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
