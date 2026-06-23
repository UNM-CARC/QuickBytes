# MATLAB at CARC

## Software Description

MATLAB is used for numerical computing and analysis. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `matlab/slurm-test.sh`: `pass`, job `806461`, elapsed `00:00:40`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.sh
# This script demonstrates MATLAB Parallel Computing Toolbox on one node.

# Slurm resources for a shared-memory MATLAB parallel example.
#SBATCH --job-name=test-matlab-parallel
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=6G
#SBATCH --time=00:10:00

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/matlab/slurm-test.sh" ]]; then
    script_dir="$script_dir/matlab"
fi

# Fundamental: reset modules and load MATLAB.
module purge
module load matlab/R2024b

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Test harness: write a MATLAB program that opens a local parallel pool and
# performs one matrix-multiply task per Slurm CPU.
cat > matlab_parallel_test.m <<'EOF'
workers = str2double(getenv('SLURM_CPUS_PER_TASK'));
if isnan(workers) || workers < 1
    workers = 1;
end

pool = gcp('nocreate');
if isempty(pool)
    pool = parpool('local', workers);
end

parts = zeros(workers, 1);
parfor idx = 1:workers
    rng(20260623 + idx);
    A = rand(700, 700);
    B = rand(700, 700);
    C = A * B;
    parts(idx) = sum(C(:));
end

total = sum(parts);
fid = fopen('matlab-parallel.out', 'w');
fprintf(fid, 'workers=%d\n', workers);
fprintf(fid, 'total=%.6f\n', total);
fclose(fid);

assert(isfinite(total) && total > 0);
delete(pool);
exit;
EOF

# Fundamental: run MATLAB in noninteractive batch mode.
matlab -batch "matlab_parallel_test"
# Test check: confirm MATLAB used the requested worker count.
grep -q "workers=${SLURM_CPUS_PER_TASK}" matlab-parallel.out
# Test check: confirm MATLAB produced a numeric result.
grep -q "total=" matlab-parallel.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: matlab/slurm-test.sh
Job ID: 806461
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:40
Allocated nodes: 1
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
