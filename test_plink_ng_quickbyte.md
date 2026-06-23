# PLINK 2 at CARC

## Software Description

PLINK 2 is used for whole-genome association and population-genetics analyses. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `plink-ng/single-node/slurm-test.sh`: `pass`, job `806479`, elapsed `00:00:01`, CPUs `2`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script converts tiny PED/MAP data and computes allele frequencies.

# Slurm resources for this short threaded PLINK2 example.
#SBATCH --job-name=test-plink-ng
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -d "$script_dir/plink-ng/single-node" ]]; then
    script_dir="$script_dir/plink-ng/single-node"
fi

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Fundamental: load PLINK2.
module --ignore-cache load plink-ng/v2.0.0-a.7.1

# Test harness: write tiny PED genotype data.
cat > cohort.ped <<'EOF'
FAM1 IND1 0 0 1 1 A A C C G G
FAM1 IND2 0 0 2 1 A G C C G T
FAM2 IND3 0 0 1 2 G G C T T T
EOF
# Test harness: write the matching MAP marker file.
cat > cohort.map <<'EOF'
1 rs1 0 100
1 rs2 0 200
1 rs3 0 300
EOF

# Fundamental: convert PED/MAP to binary PLINK format using Slurm CPU count.
plink2 --ped cohort.ped --map cohort.map --make-bed --out cohort --threads "${SLURM_CPUS_PER_TASK}"
# Fundamental: compute allele frequencies from the binary PLINK dataset.
plink2 --bfile cohort --freq --out cohort_freq --threads "${SLURM_CPUS_PER_TASK}"

# Test check: confirm binary PLINK output was created.
test -s cohort.bed
# Test check: confirm the expected marker appears in allele-frequency output.
grep -q "rs1" cohort_freq.afreq
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: plink-ng/single-node/slurm-test.sh
Job ID: 806479
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 1
Allocated CPUs: 2
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
