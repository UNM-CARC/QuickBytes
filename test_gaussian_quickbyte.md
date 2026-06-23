# Gaussian at CARC

## Software Description

Gaussian is available as a CARC software module. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `pbs_examples/gaussian/gaussian16_linda.slurm`: `pass`, job `806472`, elapsed `00:01:23`, CPUs `16`
- `pbs_examples/gaussian/gaussian16_serial.slurm`: `pass`, job `806476`, elapsed `00:00:31`, CPUs `8`
- `pbs_examples/gaussian/gaussian16_linda_water.slurm`: `pass`, job `806475`, elapsed `00:00:06`, CPUs `8`
- `pbs_examples/gaussian/gaussian16_linda_caffeine.slurm`: `pass`, job `806474`, elapsed `00:00:08`, CPUs `8`
- `pbs_examples/gaussian/gaussian16_linda_acetylchloride.slurm`: `pass`, job `806473`, elapsed `00:00:20`, CPUs `16`

## Example Slurm Script

Save the following as `gaussian16_linda.slurm` in the example directory and submit it with `sbatch gaussian16_linda.slurm`.

```bash
#!/bin/bash -l
# Run this file with: sbatch gaussian16_linda.slurm
# This script demonstrates a two-node Gaussian Linda run.

# Slurm resources for a Gaussian Linda parallel example.
#SBATCH --job-name=test-gaussian16-linda
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Fundamental: run from the directory where sbatch was submitted.
cd "${SLURM_SUBMIT_DIR:-$PWD}"

# Fundamental: load Gaussian 16.
module load gaussian/g16

# Fundamental: enable verbose Linda diagnostics in the Gaussian log.
export GAUSS_LFLAGS="-v"
# Fundamental: declare the Linda worker host list variable before assigning it.
export GAUSS_WDEF
# Fundamental: set the number of Linda workers from the Slurm task count.
export GAUSS_PDEF="${SLURM_NTASKS}"
# Fundamental: convert Slurm's allocated host names into Gaussian's comma list.
GAUSS_WDEF="$(scontrol show hostnames "$SLURM_JOB_NODELIST" | paste -sd, -)"

# Test harness: print the parallel layout for users to inspect.
echo "Parallelizing ${GAUSS_PDEF} Linda workers across ${GAUSS_WDEF}."
# Fundamental: run Gaussian on the HCl input and write HCl.log.
g16 HCl.gjf HCl.log
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: pbs_examples/gaussian/gaussian16_linda.slurm
Job ID: 806472
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:01:23
Allocated nodes: 2
Allocated CPUs: 16
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
