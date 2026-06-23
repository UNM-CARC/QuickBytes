# BEAST2 at CARC

## Software Description

BEAST2 is used for Bayesian evolutionary analysis. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `beast2/slurm-test.sh`: `pass`, job `806444`, elapsed `00:00:02`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.sh
# This script demonstrates a short BEAST2 MCMC run.

# Slurm resources for a short threaded BEAST2 example.
#SBATCH --job-name=test-beast2
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=00:05:00

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/beast2/slurm-test.sh" ]]; then
    script_dir="$script_dir/beast2"
fi

# Fundamental: reset modules and load Java, compiler dependency, and BEAST2.
module purge
module load openjdk/17.0.11_9-gz7cljt
module load llvm/17.0.6-ahyd
module load beast2/2.7.4-mh57

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Test harness: copy a packaged BEAST2 example XML into the run directory.
cp "${BEAST2_ROOT}/examples/bitflip.xml" .
# Test harness: shorten the packaged example so the regression test finishes quickly.
sed -i 's/chainLength="100000"/chainLength="50000"/' bitflip.xml

# Fundamental: run BEAST2 using the CPU count requested from Slurm.
beast -threads "${SLURM_CPUS_PER_TASK}" -overwrite bitflip.xml > beast2.out
# Test check: confirm BEAST2 produced its log file.
test -s bitflip.log
# Test check: confirm BEAST2 reported final timing information.
grep -q "Total calculation time" beast2.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: beast2/slurm-test.sh
Job ID: 806444
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:02
Allocated nodes: 1
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
