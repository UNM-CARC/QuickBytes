# Apache Spark on Easley

Apache Spark is a distributed computing framework for processing large data sets, generally easier to program than something like MPI. You write a single Python (or Java/Scala) program that coordinates parallel work across many worker processes.

This tutorial assumes you're comfortable with Slurm, modules, and HPC basics, but new to Spark. Each step explains *why* it's needed — Spark's main complication on a shared HPC cluster isn't writing Spark code, it's standing up your own personal Spark cluster inside Slurm's allocation system. All files are at <https://github.com/Graviton28/QuickBytes/tree/master/spark>.

---

## Why Spark Needs Special Handling Here

Most jobs you run on Easley are a single program Slurm starts and stops. Spark expects to run as its own long-lived cluster — one master process plus one or more workers, coordinating over the network. But Slurm only gives you nodes temporarily, and which nodes you get changes every time. The `slurm-spark-submit` script below exists to solve exactly this: every time you get an allocation, it builds a correctly-configured Spark cluster on whatever nodes you were given, automatically.

---

## The Spark Model, Briefly

- You write **one program** that runs on a **driver/master** node.
- The driver splits work across **worker** processes on other nodes.
- Data lives in **RDDs** (distributed collections) or, more commonly, **DataFrames** (RDDs with named columns, SQL-like operations, and native CSV/JSON/Parquet support).

The one rule that explains most Spark behavior:

- **Transformations** (`map`, `filter`, `groupBy`) are lazy — Spark just records what it'll need to do, then runs it in parallel across workers once forced to.
- **Actions** (`collect`, `count`, `show`) trigger that execution. `collect()` specifically pulls results back to the single driver process — collecting something huge can blow out driver memory even if it was fine distributed across workers.

## Word Count Example

```python
from pyspark.sql import SparkSession
from operator import add
import sys

spark = SparkSession.builder.appName("WordCount").getOrCreate()

# Transformations: lazy, distributed, nothing executes yet
lines = spark.read.text(sys.argv[1]).rdd.map(lambda r: r[0])
words = lines.flatMap(lambda line: line.split())
counts = words.map(lambda word: (word, 1)).reduceByKey(add)

# Action: this is where execution actually happens
output = counts.collect()

# Plain Python now, running only on the driver
for word, count in sorted(output, key=lambda x: -x[1])[:20]:
    print(f"{word}: {count}")
```

---

## Step 1: Load the Correct Spark Module

```bash
module load spark/3.5.1-kn2k
```

Easley has two Spack builds of Spark 3.5.1: one with Hadoop support (`kn2k`) and one without (`sewd`). Spark's standalone cluster mode needs Hadoop's jars on the classpath even if you never touch HDFS — without them you get `NoClassDefFoundError: org/slf4j/Logger` immediately on startup. **The generic `module load spark` loads the broken `sewd` build by default.** Always specify the version.

## Step 2: Fix SPARK_HOME

```bash
export SPARK_HOME=$SPARK_ROOT
```

Spark's own scripts (`start-master.sh`, `spark-submit`, etc.) expect `$SPARK_HOME`. The Easley module only sets `$SPARK_ROOT`. Skip this and nothing Spark-related can find its own installation.

## Step 3: Match Driver and Worker Python Versions

```bash
module load miniforge3
conda create -n spark-env python=3.11 numpy scipy pandas matplotlib pyarrow -y
conda activate spark-env
export PYSPARK_PYTHON=~/.conda/envs/spark-env/bin/python
export PYSPARK_DRIVER_PYTHON=~/.conda/envs/spark-env/bin/python
```

PySpark runs your code on both the driver and every worker, and they must run the same minor Python version. Easley's system Python is 3.9; if your conda env is 3.11, you'll hit:
```
PySparkRuntimeError: [PYTHON_VERSION_MISMATCH] Python in worker has
different version (3, 9) than that in driver 3.11
```
`PYSPARK_DRIVER_PYTHON` controls the driver's interpreter, `PYSPARK_PYTHON` controls the workers' — you need both set, not just one.

---

## Step 4: What `slurm-spark-submit` Actually Does

Spark standalone clusters normally expect fixed, known hostnames — you SSH to one node and start a master, then SSH to every other node to start workers pointed at it. That doesn't work when your nodes change every allocation. The script automates this:

1. Loads the module and fixes the environment variables from Steps 1–3.
2. Asks Slurm for the current node list: `scontrol show hostnames "$SLURM_JOB_NODELIST"`.
3. Starts the master directly on the first node.
4. SSHes into every allocated node and starts a worker — explicitly passing `SPARK_HOME`, `JAVA_HOME`, `SPARK_DIST_CLASSPATH`, and `PYSPARK_PYTHON` into each session, since a fresh `ssh` session doesn't inherit your shell's environment. Skip this and every worker hits the same classpath and Python errors all over again.
5. Redirects all Spark logs/work/pid directories to `/tmp/spark-$SLURM_JOB_ID/`, since the shared Spark install directory is read-only.
6. If you pass it a script, runs it with `spark-submit` and tears the cluster down afterward (for use inside `sbatch`). If not, it leaves the cluster running for interactive use and prints the master URL.

---

## Step 5: Interactive Use

```bash
salloc --nodes=1 --ntasks-per-node=1 --cpus-per-task=4 --mem=16G --time=00:30:00 --partition=general
module load spark/3.5.1-kn2k
./slurm-spark-submit
```

Note the printed `MASTER_URL` (e.g. `spark://easley002:7077`) — it changes every allocation since it depends on which node you got. Connect with:

```bash
export PYSPARK_PYTHON=~/.conda/envs/spark-env/bin/python
export PYSPARK_DRIVER_PYTHON=~/.conda/envs/spark-env/bin/python
pyspark --master spark://easley002:7077
```

```python
>>> sc.parallelize(range(100)).sum()
4950
```
This forces an actual distributed computation and round-trip, confirming master, worker, networking, and Python compatibility all work — not just that processes exist.

---

## Step 6: Batch Jobs

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:10:00
#SBATCH --output=wordcount_%j.log
#SBATCH --partition=general

module load spark/3.5.1-kn2k
export SPARK_HOME=$SPARK_ROOT

SCRATCHDIR="/tmp/spark-${SLURM_JOB_ID}"
mkdir -p "$SCRATCHDIR"
cp "$SLURM_SUBMIT_DIR/wordcount.py" "$SCRATCHDIR/"
cp "$SLURM_SUBMIT_DIR/big.txt"      "$SCRATCHDIR/"
cd "$SCRATCHDIR"

bash "$SLURM_SUBMIT_DIR/slurm-spark-submit" \
    wordcount.py big.txt > wordcount.log 2>&1

cp wordcount.log "$SLURM_SUBMIT_DIR/"
```

Standard pattern: copy inputs to local `/tmp` scratch for faster I/O, `$SLURM_SUBMIT_DIR` tracks where you originally ran `sbatch` from since the script `cd`s away from it, and results get copied back at the end. Submit and monitor as usual:
```bash
sbatch wordcount.sh
squeue --me
```

---

## Step 7: Multi-Node Scaling

```bash
salloc --nodes=2 --ntasks-per-node=1 --cpus-per-task=4 --mem=16G --time=00:30:00 --partition=general
./slurm-spark-submit
```

Nothing else changes — the script re-queries Slurm's node list every run, so it scales from 1 to N nodes with no edits.

One quirk on this Spack build: master/worker `.out` logs in `/tmp/spark-$SLURM_JOB_ID/logs/` may show only the Java launch line with nothing after it. That's a logging config quirk, not a failure. Verify health with process/port checks instead:
```bash
ps aux | grep -E "Master|Worker" | grep -v grep
ss -tlnp | grep 7077
```

To confirm work actually spread across nodes, not just that processes exist:
```python
>>> sc.parallelize(range(1000), 32).mapPartitions(lambda it: [sum(1 for _ in it)]).collect()
[31, 31, 31, 32, ...]
```
32 nonzero partition counts means the data was actually split and processed across your workers.

---

## Step 8: DataFrames and Plotting

Aggregate inside Spark, then bring only the small result back to Pandas:

```python
import matplotlib
matplotlib.use("PDF")  # no display on compute nodes
import matplotlib.pyplot as plt
import pandas as pd
from pyspark.sql.functions import month

monthly = (
    df.withColumn("Month", month("Date"))
    .groupBy("Month").count()
    .orderBy("Month")
    .collect()          # only action in the chain — result is tiny by now
)

pdf = pd.DataFrame(monthly, columns=["month", "crime_count"])
pdf.plot(figsize=(20, 10), kind="line", x="month", y="crime_count")
plt.savefig("crimes-by-month.pdf")
```

The grouping/counting happens distributed across all workers before anything leaves the cluster; only the final handful of rows gets pulled into Pandas/Matplotlib, which are single-machine tools never meant to handle the full raw dataset directly.

---

## Known Issues on Easley

| Symptom | Cause | Fix |
|---|---|---|
| `NoClassDefFoundError: org/slf4j/Logger` | Default `module load spark` loads the Hadoop-less `sewd` build | `module load spark/3.5.1-kn2k` |
| Spark scripts can't find their install | Module sets `$SPARK_ROOT`, not `$SPARK_HOME` | `export SPARK_HOME=$SPARK_ROOT` |
| `PYTHON_VERSION_MISMATCH` | conda env Python ≠ system Python (3.9) used by workers | Set both `PYSPARK_PYTHON` and `PYSPARK_DRIVER_PYTHON` |
| Worker/master logs look empty | Logging config quirk in this build | Check `ps aux` / `ss -tlnp` instead of logs |

---

## Further Reading

- **Spark Streaming** — same transformation/action model applied to continuously-arriving data in time-windowed batches.
- **Spark ML** — built-in distributed ML algorithms using the same partitioning model.
- **Spark SQL** — run actual SQL against DataFrames via `spark.sql(...)`.
- Official docs: <https://spark.apache.org/docs/3.5.1/>
