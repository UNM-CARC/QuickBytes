# GNU Parallel

GNU Parallel enables us to run many jobs in parallel instead of sequentially, saving significant time. Unlike a sequential queue, GNU Parallel maximally parallelizes execution across available processors in an embarrassingly parallel fashion.

For example, the following command finds all files with a `.csv` extension and converts them to `.txt` format:

```bash
module load image-magick-7.0.5-9-gcc-4.8.5-python2-xzyy5cz
find . -name "*csv" | parallel -I% --max-args 1 convert % %.txt
```

GNU Parallel can also be used to compress and decompress many files at once:

```bash
# Compress all .txt files
parallel gzip ::: *.txt

# Decompress all .gz files
parallel gunzip ::: *.gz
```

## MATLAB Implementation of GNU Parallel

GNU Parallel takes many different arguments, but here we will use only two: `--arg-file` and `{}`. `--arg-file` precedes an input filename, and `{}` is replaced with each line of that input file. A different copy of MATLAB is run simultaneously for each line, making this MATLAB in high-throughput mode on a single node:

```bash
parallel --arg-file msizes 'matlab -nojvm -nodisplay -r "msize={};program"' >/dev/null
```

Single quotes are required around the MATLAB portion of the command, and the actual MATLAB code is enclosed in double quotes. Given an input file `msizes` containing:

```
1
2
3
4
```

This creates four output files: `1.csv`, `2.csv`, `3.csv`, and `4.csv`. For example, `3.csv` would contain a 3x3 matrix of random numbers:

```
0.81472,0.91338,0.2785
0.90579,0.63236,0.54688
0.12699,0.09754,0.95751
```

### High-Throughput Mode

Running on a single node does not take advantage of CARC's large-scale resources. To run MATLAB in high-throughput mode across multiple nodes, we use an Sbatch script. Before doing so, `program.m` needs to be updated to prepend the parent process ID to each output filename, ensuring all output files have unique names:

```matlab
%generate a matrix of random numbers of dimension msize x msize
rmatrix=rand(msize);
%create a unique output name based on the node hostname, process id#,
%and msize and write the random matrix to it
[~,hname]=system('hostname');
fname=num2str(msize);
process=num2str(pid);
fname=strcat(strtrim(hname),'.',process,'.',fname,'.csv');
csvwrite(fname,rmatrix);
quit
```

The updated parallel MATLAB command, now using `-j0` to use as many cores as possible, is:

```bash
parallel -j0 --arg-file msizes 'matlab -nojvm -nodisplay -r "msize={};pid=$PPID;program"' >/dev/null
```

The corresponding Sbatch script to run this across multiple nodes is:

```bash
#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --time=00:30:00
#SBATCH --job-name=matlab_test
#SBATCH --output=matlab_test.out
#SBATCH --error=matlab_test.err

cd $SLURM_SUBMIT_DIR
module load matlab/R2024b
module load parallel/20240822-ao2z

# Expand SLURM's compressed node list to one hostname per line
scontrol show hostnames $SLURM_JOB_NODELIST > nodefile.txt

echo starting Matlab jobs at $(date)
parallel -j0 --sshloginfile nodefile.txt --workdir $SLURM_SUBMIT_DIR \
    --env PATH --arg-file msizes \
    'matlab -nojvm -nodisplay -r "msize={};pid=$$;program" >/dev/null'
echo finished Matlab jobs at $(date)
```

With the `msizes` input file containing 8 entries (one per core allocated):

```
1
2
3
4
5
6
7
8
```

It is very important to match the number of cores allocated to the number of lines in `msizes`. Use this equation as your guide:

**nodes × ntasks-per-node = cores allocated = lines in msizes = MATLAB processes run**

Running more MATLAB processes than allocated cores will cause jobs to queue behind each other and significantly slow execution. Running fewer wastes allocated resources. For information on the number of cores per node available on each CARC machine, see the Systems page.

The flags in the parallel command serve the following purposes:

- `--sshloginfile nodefile.txt` — provides the hostnames of all nodes allocated by SLURM. Note that `$SLURM_JOB_NODELIST` uses a compressed format (e.g. `easley[014-015]`) that GNU Parallel cannot read directly, so we first expand it to one hostname per line using `scontrol show hostnames`.
- `--workdir $SLURM_SUBMIT_DIR` — forces MATLAB to run in the directory where the script was submitted
- `--env PATH` — ensures all MATLAB processes inherit the same environment variables as the Sbatch script, including those set by `module` commands

### Submitting the Job

Save the Sbatch script to a file, e.g. `mtest.sh`, and submit it:

```bash
sbatch mtest.sh
```

This should produce 8 output files containing random matrices of sizes 1×1 through 8×8, named in the format `hostname.pid.size.csv`. Output and error from the job will be written to `matlab_test.out` and `matlab_test.err` respectively.

---

## Running Embarrassingly Parallel Python Jobs

The usage of GNU Parallel for Python tasks is similar to MATLAB. Below is an example that uses GNU Parallel to run matrix inversion jobs across multiple nodes.

### Sbatch Script

```bash
#!/bin/bash
#SBATCH --job-name=gnu_parallel_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --time=01:00:00
#SBATCH --output=python_parallel.out
#SBATCH --error=python_parallel.err

cd $SLURM_SUBMIT_DIR

# load GNU Parallel
module load parallel/20240822-ao2z

# load Python and numpy
module load miniconda3/latest
module load py-numpy/1.26.4-pzxr

# Expand SLURM's compressed node list to one hostname per line
scontrol show hostnames $SLURM_JOB_NODELIST > nodefile.txt

/usr/bin/time -o time.log parallel --joblog logfile --wd $SLURM_SUBMIT_DIR \
    -j0 --sshloginfile nodefile.txt \
    --env PATH --env LD_LIBRARY_PATH --env PYTHONPATH \
    -a mat_in python matrix_inv.py
```

### Python Script: `matrix_inv.py`

```python
import numpy
from numpy.random import rand
from numpy.linalg import inv
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("matrix", type=int, help='provide single integer for matrix dimensions')
args = parser.parse_args()

def matinv(x):
    mat = rand(x, x)
    b = inv(mat)
    return b

out = matinv(args.matrix)
numpy.savetxt("%d.csv" % args.matrix, out, delimiter=",")
```

### Input File: `mat_in`

```
1000
2000
3000
4000
5000
6000
7000
8000
```

Each line represents the dimension of a matrix to invert. As with the MATLAB example, the number of lines should match the total number of cores allocated (nodes × ntasks-per-node). After a successful run you should find 8 output files named `1000.csv` through `8000.csv`, and a `logfile` showing the runtime and exit code for each task.

*This quickbyte was validated on 6/9/2026*