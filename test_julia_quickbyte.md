# Julia at CARC

## Software Description

Julia is a high-level language for scientific computing. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `julia/slurm-test.sh`: `pass`, job `806457`, elapsed `00:00:04`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.sh
# This script demonstrates Julia threads inside one Slurm task.

# Slurm resources for a shared-memory Julia example.
#SBATCH --job-name=test-julia-threads
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
if [[ -f "$script_dir/julia/slurm-test.sh" ]]; then
    script_dir="$script_dir/julia"
fi

# Fundamental: reset modules and load Julia.
module purge
module load julia/1.8.5

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Test harness: write a small threaded Julia program into the run directory.
cat > threaded_pi.jl <<'EOF'
using Base.Threads
using Random

workers = nthreads()
samples_per_worker = 20_000_000
hits = zeros(Int, workers)

@threads for tid in 1:workers
    rng = MersenneTwister(20260623 + tid)
    local_hits = 0
    for _ in 1:samples_per_worker
        x = rand(rng)
        y = rand(rng)
        local_hits += (x*x + y*y <= 1)
    end
    hits[tid] = local_hits
end

pi_estimate = 4 * sum(hits) / (samples_per_worker * workers)
open("julia-threads.out", "w") do io
    println(io, "threads=$(workers)")
    println(io, "samples=$(samples_per_worker * workers)")
    println(io, "pi_estimate=$(round(pi_estimate, digits=6))")
end

abs(pi_estimate - pi) <= 0.02 || error("threaded Monte Carlo estimate is outside expected tolerance")
EOF

# Fundamental: set Julia's thread count from the CPUs requested from Slurm.
JULIA_NUM_THREADS="${SLURM_CPUS_PER_TASK}" julia threaded_pi.jl
# Test check: confirm Julia used the requested thread count.
grep -q "threads=${SLURM_CPUS_PER_TASK}" julia-threads.out
# Test check: confirm the Monte Carlo result was written.
grep -q "pi_estimate=" julia-threads.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: julia/slurm-test.sh
Job ID: 806457
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:04
Allocated nodes: 1
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
