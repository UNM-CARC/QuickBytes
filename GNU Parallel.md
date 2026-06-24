# GNU Parallel at CARC

## Overview

GNU Parallel allows you to run multiple independent jobs simultaneously instead of sequentially, reducing total execution time.

Instead of creating a queue of processes that execute one after another, GNU Parallel distributes work across available CPU resources. This approach is especially effective for embarrassingly parallel workloads, where tasks do not depend on one another.

Typical use cases include:

* Batch file conversion
* Compression and decompression
* Parameter sweeps
* High-throughput MATLAB workflows
* Parallel Python execution

---

## Basic GNU Parallel Examples

### Converting Files in Parallel

The following example converts all `.csv` files into `.txt` files.

```bash
module load imagemagick

find . -name "*.csv" | parallel convert {} {.}.txt
```

This command:

1. Finds all files ending in `.csv`
2. Passes each file to GNU Parallel
3. Executes conversions concurrently

`{}` represents the full filename and `{.}` removes the extension.

---

### Compressing and Decompressing Files

Compress files:

```bash
parallel gzip ::: *.txt
```

Decompress files:

```bash
parallel gunzip ::: *.gz
```

This pattern also works for collections of images or other independent files.

---

## MATLAB with GNU Parallel

GNU Parallel supports running many MATLAB processes simultaneously.

Two commonly used features are:

* `--arg-file` — read inputs from a file
* `{}` — substitute each input line into the command

Assume an input file named `msizes`:

```text
1
2
3
4
```

Launch MATLAB once per line:

```bash
parallel --arg-file msizes \
'matlab -batch "msize={}; program"'
```

This launches four MATLAB jobs simultaneously.

`matlab -batch` is preferred over older combinations such as `-nojvm -nodisplay -r`.

---

### Example MATLAB Program

`program.m`

```matlab
% Generate a random matrix
rmatrix = rand(msize);

% Create output filename
fname = sprintf('%d.csv', msize);

% Save results
writematrix(rmatrix, fname);

exit
```

Example output:

```text
1.csv
2.csv
3.csv
4.csv
```

---

## Running MATLAB at Scale with Slurm

Running large numbers of MATLAB jobs directly on login nodes is not recommended, so please use Slurm to allocate compute resources.

Example Slurm submission script:

```bash
#!/bin/bash

#SBATCH --job-name=matlab_parallel
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --time=00:10:00

module load matlab
module load parallel

cd "$SLURM_SUBMIT_DIR"

echo "Starting MATLAB jobs at $(date)"

parallel \
    -j "$SLURM_NTASKS" \
    --arg-file msizes \
    'matlab -batch "msize={}; program"'

echo "Finished at $(date)"
```

Submit the job:

```bash
sbatch matlab_parallel.slurm
```

---

## Matching Jobs to Resources

When using GNU Parallel, the number of jobs should approximately match the number of allocated tasks.

General guideline:

```text
nodes × tasks-per-node ≈ number of parallel jobs
```

Examples:

| Nodes | Tasks per Node | Parallel Jobs |
| ----- | -------------- | ------------- |
| 1     | 8              | 8             |
| 2     | 8              | 16            |
| 4     | 16             | 64            |

Running substantially more jobs than available CPU resources may increase runtime due to oversubscription.

---

## Running Embarrassingly Parallel Python Jobs

GNU Parallel can also distribute Python workloads.

### Example Slurm Script

```bash
#!/bin/bash

#SBATCH --job-name=gnu_parallel_python
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --time=01:00:00

module load parallel
module load anaconda

source activate numpy_py3

cd "$SLURM_SUBMIT_DIR"

parallel \
    -j "$SLURM_NTASKS" \
    --arg-file mat_in \
    python matrix_inv.py
```

---

### Example Python Program

`matrix_inv.py`

```python
import argparse
import numpy as np
from numpy.random import rand
from numpy.linalg import inv


parser = argparse.ArgumentParser()
parser.add_argument("matrix", type=int)

args = parser.parse_args()


def matinv(size):
    return inv(rand(size, size))


result = matinv(args.matrix)

np.savetxt(
    f"{args.matrix}.csv",
    result,
    delimiter=","
)
```

---

### Example Input File

`mat_in`

```text
1000
2000
3000
4000
5000
6000
7000
8000
```

Each line becomes one parallel task.

Submit with:

```bash
sbatch python_parallel.slurm
```

---

## Notes

* Use Slurm allocations for production workloads.
* GNU Parallel works best for independent tasks with minimal communication.
* Match the number of jobs to allocated resources whenever possible.

---

*This QuickByte was updated and validated on June 23, 2026.*
