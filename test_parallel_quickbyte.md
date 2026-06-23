# GNU Parallel at CARC

## Software Description

GNU Parallel is available as a CARC software module. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `parallel/slurm-test.sh`: `pass`, job `806470`, elapsed `00:00:01`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.sh
# This script demonstrates GNU Parallel on one node.

# Slurm resources for an embarrassingly parallel single-node example.
#SBATCH --job-name=test-gnu-parallel
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=2G
#SBATCH --time=00:05:00

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/parallel/slurm-test.sh" ]]; then
    script_dir="$script_dir/parallel"
fi

# Fundamental: reset modules and load GNU Parallel.
module purge
module load parallel/20240822-ao2z

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Test harness: create eight small task IDs for GNU Parallel.
seq 1 8 > tasks.txt

# Fundamental: run one Python hashing task per input line, up to the Slurm CPU count.
parallel --jobs "${SLURM_CPUS_PER_TASK}" --joblog parallel.joblog \
    'python3 -c "import hashlib, sys; n=int(sys.argv[1]); payload=(str(n)*2000000).encode(); print(f\"{n}\t{hashlib.sha256(payload).hexdigest()}\")" {} > result-{}.txt' \
    :::: tasks.txt

# Test harness: combine task outputs in numeric order.
cat result-*.txt | sort -n > parallel-results.tsv
# Test check: confirm all eight tasks produced output.
test "$(wc -l < parallel-results.tsv)" -eq 8
# Test check: confirm every GNU Parallel task exit code was zero.
awk 'NR > 1 { if ($7 != 0) exit 1 }' parallel.joblog
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: parallel/slurm-test.sh
Job ID: 806470
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 1
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
