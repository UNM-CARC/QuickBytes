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

> **Known issue:** the `imagemagick` module is currently unavailable on Easley. A fix is expected within a day — until then, skip this example.

The following example converts all `.csv` files into `.txt` files.

```bash
module load parallel
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

`parallel` isn't on your `PATH` by default — load it once per session:

```bash
module load parallel
```

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

Create an input file named `msizes`:

```bash
cat > msizes <<'EOF'
1
2
3
4
EOF
```

And the MATLAB program it drives, `program.m`:

```bash
cat > program.m <<'EOF'
% Generate a random matrix
rmatrix = rand(msize);

% Create output filename
fname = sprintf('%d.csv', msize);

% Save results
writematrix(rmatrix, fname);

exit
EOF
```

Running large numbers of MATLAB jobs directly on the login node is not allowed — request an interactive allocation first:

```bash
srun --nodes=1 --ntasks-per-node=4 --pty bash
```

Then, on the allocated compute node, load both modules and launch MATLAB once per line in `msizes`:

```bash
module load matlab
module load parallel

parallel --arg-file msizes \
    'matlab -batch "msize={}; program"'
```

This launches four MATLAB jobs simultaneously.

`matlab -batch` is preferred over older combinations such as `-nojvm -nodisplay -r`.

Example output:

```text
1.csv
2.csv
3.csv
4.csv
```

---

## Running Across Multiple Nodes with `--sshloginfile`

Slurm allocates the nodes for your job, but GNU Parallel has no automatic awareness of any node besides the one your script is actually running on. Without telling it otherwise, `parallel -j N` runs all `N` jobs on that single node — oversubscribing it — rather than spreading them across every node you requested with `--nodes`.

To actually use every allocated node, pass `--sshloginfile "$CARC_NODEFILE"`. CARC's Slurm setup exposes the list of nodes in your current allocation through the `$CARC_NODEFILE` environment variable (the Slurm-era equivalent of the old PBS `$PBS_NODEFILE`).

You can confirm this yourself on an interactive multi-node allocation:

```bash
srun --nodes 2 --pty bash
```

```bash
echo $CARC_NODEFILE
cat $CARC_NODEFILE
```

When you add `--sshloginfile`, set `-j` to the tasks **per node** (`$SLURM_NTASKS_PER_NODE`), not the job's total task count (`$SLURM_NTASKS`) — `--sshloginfile` already handles spreading work across nodes, so using the total would oversubscribe each individual node instead.

### One-Time Setup: Passwordless SSH Between Compute Nodes

`--sshloginfile` works by having GNU Parallel `ssh` from the node running your script to every other node in your allocation. Since your home directory is shared (NFS) across all compute nodes, you only need to do this once, ever — not per job.

**1. Generate a keypair and trust it for yourself** — this checks first and does nothing if you already have one:

```bash
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
fi
grep -qxF "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys 2>/dev/null \
    || cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys ~/.ssh/id_ed25519
```

If you already use `~/.ssh/id_ed25519` for something else (e.g. GitHub), use a different filename (e.g. `~/.ssh/id_ed25519_carc`) throughout this section instead — just make sure the same key ends up in your own `authorized_keys`.

**2. Pre-trust every node's host key**, so a job landing on a node you've never connected to before doesn't hang waiting on a host-key prompt that a batch script has no terminal to answer:

```bash
for i in $(seq -w 1 63); do echo easley0$i; done | ssh-keyscan -f - >> ~/.ssh/known_hosts 2>/dev/null
```

Without both of these steps, a `--sshloginfile` job will silently hang until it hits its time limit — there's no error message, since the script is stuck waiting on a password/host-key prompt that never arrives.

---

## Running MATLAB at Scale with Slurm

Running large numbers of MATLAB jobs directly on login nodes is not recommended, so please use Slurm to allocate compute resources.

Create the submission script (uses the same `msizes` and `program.m` from the single-node example above — recreate them here if you're starting fresh):

```bash
cat > matlab_parallel.slurm <<'EOF'
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
    -j "$SLURM_NTASKS_PER_NODE" \
    --sshloginfile "$CARC_NODEFILE" \
    --workdir "$SLURM_SUBMIT_DIR" \
    --env PATH \
    --arg-file msizes \
    'matlab -batch "msize={}; program"'

echo "Finished at $(date)"
EOF
```

`--workdir "$SLURM_SUBMIT_DIR"` is required because SSH sessions default to your home directory, not wherever this script's own `cd` took you — without it, MATLAB can't find `program.m`. `--env PATH` forwards the module-loaded PATH (with `matlab` on it) to the remote SSH sessions, which otherwise start with a bare, non-login environment that doesn't have `module`-loaded paths at all.

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

### One-Time Setup: Conda Environment

Create the environment this example uses (only needs to be done once):

```bash
module load miniconda3
conda create -n numpy_py3 python=3.11 numpy -y
```

### Example Python Program

Create `matrix_inv.py`:

```bash
cat > matrix_inv.py <<'EOF'
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
EOF
```

---

### Example Input File

Create `mat_in` — each line becomes one parallel task:

```bash
cat > mat_in <<'EOF'
1000
2000
3000
4000
5000
6000
7000
8000
EOF
```

---

### Example Slurm Script

```bash
cat > python_parallel.slurm <<'EOF'
#!/bin/bash

#SBATCH --job-name=gnu_parallel_python
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --time=01:00:00

module load parallel
module load miniconda3

source activate numpy_py3

cd "$SLURM_SUBMIT_DIR"

parallel \
    -j "$SLURM_NTASKS_PER_NODE" \
    --sshloginfile "$CARC_NODEFILE" \
    --workdir "$SLURM_SUBMIT_DIR" \
    --env PATH \
    --arg-file mat_in \
    python matrix_inv.py
EOF
```

Note: this uses plain `parallel` with `--env PATH`, not `env_parallel`. `env_parallel` forwards your *entire* shell environment to each remote session, and conda's activation hooks add enough bloat to that environment to blow past the shell's argument-length limit (`Command line too long`). `--env PATH` forwards just the one variable that's actually needed to find `python` in the activated environment.

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
