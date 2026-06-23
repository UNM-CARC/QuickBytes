# Running MATLAB Jobs at CARC

## MATLAB

MATLAB is a software environment and programming language designed primarily for numerical computing and matrix operations—hence the name MATrix LABoratory.

If you are unfamiliar with MATLAB, visit the MathWorks website for additional documentation and tutorials:

https://www.mathworks.com/products/matlab.html

To view available MATLAB versions on a CARC system, run:

```bash id="m1q8aa"
module avail matlab
```

MATLAB is installed on CARC systems, but must be run on compute nodes rather than login (head) nodes.

To run MATLAB jobs at CARC, submit a Slurm job that launches MATLAB in batch mode.

---

## Batch Mode

Many users are familiar with running MATLAB through the graphical interface or interactive console.

At CARC, MATLAB programs must be run non-interactively in batch mode.

Batch mode allows MATLAB to execute a script and exit automatically without launching the graphical interface.

---

## Creating a Simple MATLAB Program

Suppose you have a MATLAB script named `my_program.m` that generates a 3×3 matrix of random numbers and writes the results to a CSV file.

Example:

```matlab id="k8x2cn"
% Generate a random 3x3 matrix
rmatrix = rand(3);

% Output filename
fname = 'randnums.csv';

% Write results
writematrix(rmatrix, fname);

exit
```

Save this file in your home directory.

---

## Running MATLAB on a Compute Node (Interactive)

If you want to test interactively, first request a compute node:

```bash id="q7v1sp"
srun --pty bash
```

Once on the compute node:

```bash id="p0d8xy"
module load matlab
matlab -batch "my_program"
```

This ensures MATLAB runs on a compute node, not the login node.

---

## Running MATLAB from the Command Line (Non-Interactive)

You can also run the script directly:

```bash id="v3k9lm"
matlab -batch "my_program"
```

Notes:

* The `.m` extension is omitted
* `-batch` runs the script and exits automatically
* This is the recommended method for CARC jobs

---

## Submitting a MATLAB Job with Slurm

Create a submission script named `my_matlab_job.sbatch`.

```bash id="x2n5ad"
#!/bin/bash

#SBATCH --job-name=my_matlab_job
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=my_email@unm.edu
#SBATCH --output=slurm-%j.out

module load matlab

matlab -batch "my_program"
```

Submit the job from your home directory:

```bash id="c4w8pq"
sbatch my_matlab_job.sbatch
```

---

## Important Notes

* MATLAB jobs must run on compute nodes, not login nodes.
* Do not run `.m` files directly with `srun`; they must be executed through MATLAB.
* Use `srun --pty bash` for interactive compute access when debugging.
* Easley uses Slurm. PBS may still exist on Hopper, but Slurm is recommended for all workflows.

---

## Viewing Output

All output is written to:

```text id="z1r8tt"
slurm-<jobid>.out
```

Monitor output live with:

```bash id="t6v9gh"
tail -f slurm-<jobid>.out
```

---

## Commands Used (for Debugging)

```bash id="a8m3kf"
module avail matlab
```

List available MATLAB versions.

```bash id="k2v9sd"
srun --pty bash
```

Request an interactive compute node session.

```bash id="u7p1wx"
module load matlab
```

Load MATLAB module.

```bash id="m9c2qa"
matlab -batch "my_program"
```

Run MATLAB script in batch mode.

```bash id="b5n7ld"
sbatch my_matlab_job.sbatch
```

Submit job to Slurm.

```bash id="r3q8yt"
tail -f slurm-<jobid>.out
```

*This QuickByte was validated on 6/23/2026*

Monitor job output.
