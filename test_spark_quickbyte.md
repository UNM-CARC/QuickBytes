# Spark at CARC

## Software Description

Spark is a distributed data-processing engine. This QuickByte is a stub based on the CARC `test-programs` regression suite. The example is intentionally small so it can run on the `debug` partition and serve as a starting point for adapting the application to a real research workload.

Passing test-program examples used for this stub:

- `spark/slurm-test.sh`: `pass`, job `806487`, elapsed `00:00:11`, CPUs `4`

## Example Slurm Script

Save the following as `slurm-test.sh` in the example directory and submit it with `sbatch slurm-test.sh`.

```bash
#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.sh
# This script demonstrates Spark local-mode parallelism inside one Slurm job.

# Slurm resources for a small local Spark wordcount example.
#SBATCH --job-name=test-spark-wordcount
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
if [[ -f "$script_dir/spark/slurm-test.sh" ]]; then
    script_dir="$script_dir/spark"
fi

# Fundamental: reset modules and load the working Spark module.
module purge
module load spark/3.5.1-kn2k

# Test harness: create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Test harness: write a tiny text input for the wordcount job.
cat > input.txt <<'EOF'
spark makes distributed data processing approachable
spark maps words across workers
slurm allocates the cores spark uses
EOF

# Test harness: write a small PySpark wordcount application.
cat > wordcount.py <<'EOF'
import sys
from operator import add
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("QuickBytesWordCount").getOrCreate()
sc = spark.sparkContext

counts = (
    sc.textFile(sys.argv[1])
    .flatMap(lambda line: line.split())
    .map(lambda word: (word.lower(), 1))
    .reduceByKey(add)
    .collect()
)

with open("wordcount.out", "w", encoding="utf-8") as handle:
    for word, count in sorted(counts):
        handle.write(f"{word}\t{count}\n")

spark.stop()
EOF

# Fundamental: run Spark in local mode with worker count from Slurm CPUs.
"${SPARK_BIN}/spark-submit" --master "local[${SLURM_CPUS_PER_TASK}]" wordcount.py input.txt
# Test check: confirm Spark counted the word "spark" three times.
grep -q $'spark\t3' wordcount.out
# Test check: confirm Spark counted the word "slurm" once.
grep -q $'slurm\t1' wordcount.out
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

The following abbreviated result is from the Easley debug regression run used to validate this example.

```text
Script: spark/slurm-test.sh
Job ID: 806487
Slurm state: COMPLETED
Exit code: 0:0
Elapsed time: 00:00:11
Allocated nodes: 1
Allocated CPUs: 4
Result: pass
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and any application-specific checks in the script should pass.
