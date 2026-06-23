# NAMD at CARC

## Software Description

NAMD is a parallel molecular dynamics application. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `namd/multi-node/slurm-test.sh`: `pass_with_log_warnings`, job `806467`, elapsed `00:01:13`, CPUs `4`
- `namd/single-node/slurm-test.sh`: `pass_with_log_warnings`, job `806468`, elapsed `00:01:16`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script demonstrates multi-node NAMD with charmrun.

# Slurm resources for a two-node NAMD example.
#SBATCH --partition=debug
#SBATCH --job-name=test-namd
#SBATCH --time 00:10:00
#SBATCH --nodes 2
#SBATCH --ntasks-per-node 2
#SBATCH --mem 2GB
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# Test harness: locate this example directory when submitted from common paths.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f namd/multi-node/slurm-test.sh ]]; then
    cd namd/multi-node
elif [[ -f ../multi-node/slurm-test.sh ]]; then
    cd ../multi-node
fi

# Fundamental: load the verbs-enabled NAMD build for multi-node execution.
module load namd/2.14/verbs

# Fundamental: create a temporary node file in the format charmrun expects.
NAMD_NODEFILE=$(mktemp -p "$SLURM_SUBMIT_DIR")
# Fundamental: charmrun node files start with a group line.
echo group main > $NAMD_NODEFILE
# Fundamental: convert Slurm's allocated node list into charmrun host lines.
while IFS= read -r NODENAME; do
    echo host $NODENAME >> $NAMD_NODEFILE
done < <(scontrol show hostnames "$SLURM_JOB_NODELIST")

# Test harness: remove duplicate host lines from the temporary node file.
echo "$(sort -u $NAMD_NODEFILE)" > $NAMD_NODEFILE

# Test harness: print the generated node file for troubleshooting.
echo Wrote NAMD node file to $NAMD_NODEFILE containing:
cat $NAMD_NODEFILE

# NAMD Binaries are not SLURM aware - so we use charmrun directly
# Fundamental: launch NAMD through charmrun with one worker per Slurm task.
/usr/bin/time -v charmrun "$(which namd2)" "+p${SLURM_NTASKS}" ++nodelist "$NAMD_NODEFILE" ubq_ws_eq.conf

# Test harness: remove the temporary charmrun node file after the run.
rm "$NAMD_NODEFILE"
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: namd/multi-node/slurm-test.sh
Job ID: 806467
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:01:13
Allocated nodes: 2
Allocated CPUs: 4
Result: pass_with_log_warnings
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
