# VCFtools at CARC

## Software Description

VCFtools processes VCF variant files. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `vcftools/single-node/slurm-test.sh`: `pass`, job `806497`, elapsed `00:00:01`, CPUs `1`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
# Run this file with: sbatch slurm-test.sh
# This script filters a tiny VCF file with VCFtools.

# Slurm resources for this short VCFtools example.
#SBATCH --job-name=test-vcftools
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

# Test harness: fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Test harness: locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -d "$script_dir/vcftools/single-node" ]]; then
    script_dir="$script_dir/vcftools/single-node"
fi

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Fundamental: load VCFtools.
module --ignore-cache load vcftools/0.1.16-a6ey

# Test harness: write a tiny VCF with two PASS records and one filtered record.
cat > variants.vcf <<'EOF'
##fileformat=VCFv4.2
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	sample1	sample2
chr1	10	rs1	A	G	60	PASS	.	GT	0/1	0/0
chr1	20	rs2	C	T	10	q10	.	GT	1/1	0/1
chr1	30	rs3	G	A	99	PASS	.	GT	0/0	0/1
EOF

# Fundamental: remove filtered variants and recode the VCF.
vcftools --vcf variants.vcf --remove-filtered-all --recode --out pass_only
# Test check: confirm the recoded VCF exists and is nonempty.
test -s pass_only.recode.vcf
# Test check: confirm only the two PASS variants remain.
test "$(grep -vc '^#' pass_only.recode.vcf)" -eq 2
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: vcftools/single-node/slurm-test.sh
Job ID: 806497
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:01
Allocated nodes: 1
Allocated CPUs: 1
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
