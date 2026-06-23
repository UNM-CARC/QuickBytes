# ParaView at CARC

## Software Description

ParaView supports visualization and batch processing. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `paraview/slurm-test.sh`: `pass`, job `806471`, elapsed `00:00:09`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.sh
# This script demonstrates ParaView pvbatch on Slurm tasks.

# Slurm resources for a small parallel ParaView batch example.
#SBATCH --job-name=test-paraview-batch
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:05:00

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/paraview/slurm-test.sh" ]]; then
    script_dir="$script_dir/paraview"
fi

# Fundamental: reset modules and load ParaView.
module purge
module load paraview/6.0

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Test harness: write a small pvbatch Python pipeline.
cat > paraview_batch.py <<'EOF'
from paraview.simple import Sphere, Calculator
from paraview import servermanager

sphere = Sphere(ThetaResolution=96, PhiResolution=48)
calc = Calculator(Input=sphere)
calc.ResultArrayName = "radius_squared"
calc.Function = "coordsX*coordsX + coordsY*coordsY + coordsZ*coordsZ"
calc.UpdatePipeline()
data = servermanager.Fetch(calc)
points = data.GetNumberOfPoints()
cells = data.GetNumberOfCells()

with open("paraview-batch.out", "w", encoding="utf-8") as handle:
    handle.write("paraview_version=%s\n" % servermanager.vtkSMProxyManager.GetVersionMajor())
    handle.write("points=%d\n" % points)
    handle.write("cells=%d\n" % cells)
EOF

# Fundamental: launch pvbatch with one process per Slurm task.
srun -n "${SLURM_NTASKS}" pvbatch --force-offscreen-rendering paraview_batch.py
# Test check: confirm the pipeline produced point-count output.
grep -q "points=" paraview-batch.out
# Test check: confirm the pipeline produced cell-count output.
grep -q "cells=" paraview-batch.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: paraview/slurm-test.sh
Job ID: 806471
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:09
Allocated nodes: 1
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
