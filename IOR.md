# IOR at CARC

## Software Description

IOR is a parallel I/O benchmark for measuring read and write performance from HPC filesystems. It is useful for testing whether an MPI job can write from multiple ranks and nodes to shared storage, and for demonstrating the difference between CPU parallelism and filesystem I/O parallelism.

This example runs IOR on two Easley compute nodes with two MPI ranks per node. The test writes and reads a small shared file using POSIX I/O, so it is intended as a quick Slurm and MPI smoke test rather than a full storage benchmark.

## Example Slurm Script

Save the following as `slurm-test.sh` and submit it with `sbatch slurm-test.sh`.

```bash
#!/bin/bash -l
#SBATCH --job-name=test-ior
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

set -euo pipefail

module load openmpi/4.1.7-e7k3 ior/3.3.0-6pri

rm -f testfile*
/usr/bin/time -v srun -n "${SLURM_NTASKS}" \
    ior -w -r -b 4m -t 1m -o testfile
```

The important Slurm settings are `--nodes=2` and `--ntasks-per-node=2`, which request four MPI ranks across two nodes. `srun` launches one IOR process per rank. The `-b 4m` and `-t 1m` options keep the test small: each rank transfers 4 MiB in 1 MiB chunks, for a 16 MiB aggregate file.

## Example output

The following abbreviated output is from a completed Easley debug job using two nodes and four MPI ranks.

```text
Job 804412 running on easley[003-004]
IOR-3.3.0: MPI Coordinated Test of Parallel I/O
Command line        : ior -w -r -b 4m -t 1m -o testfile
nodes               : 2
tasks               : 4
clients per node    : 2
xfersize            : 1 MiB
blocksize           : 4 MiB
aggregate filesize  : 16 MiB

access    bw(MiB/s)  IOPS       Latency(s)  block(KiB) xfer(KiB)  total(s)
------    ---------  ----       ----------  ---------- ---------  --------
write     185.48     1391.73    0.000543    4096       1024.00    0.086260
read      177.89     180.75     0.022105    4096       1024.00    0.089945

Max Write: 185.48 MiB/sec
Max Read:  177.89 MiB/sec
```

Because this is a very small debug-queue example, the bandwidth numbers should not be treated as a filesystem benchmark result. The main check is that the job starts on multiple nodes, runs with the expected number of MPI ranks, writes and reads successfully, and exits with status `0`.
