# Prime Sieve MPI at CARC

## Software Description

Prime Sieve MPI demonstrates distributed computation by splitting a simple prime-number counting problem across multiple MPI ranks. This kind of example is useful for learning how Slurm allocates tasks across nodes and how `srun` launches an MPI program. The calculation here is intentionally small so it can run quickly on the debug partition.

## Example Slurm Script

Save the following as `mpi_test.slurm` in the example directory and submit it with `sbatch mpi_test.slurm`.

```bash
#!/bin/bash -l
# Run this file with: sbatch mpi_test.slurm
# This script builds and runs an MPI prime-sieve example.

# Slurm resources for a two-node MPI example.
#SBATCH --job-name=test-prime-sieve-mpi
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --partition=debug

# Fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Create a clean per-job output directory inside the submission directory.
submit_dir="${SLURM_SUBMIT_DIR:-$PWD}"
run_dir="$submit_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# Load an MPI implementation.
module load openmpi

# Write a compact MPI prime-counting program.
cat > mpi_prime_sieve.c <<'EOF'
#include <mpi.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

static int is_prime(int n) {
    if (n < 2) return 0;
    for (int d = 2; d <= (int)sqrt((double)n); d++) {
        if (n % d == 0) return 0;
    }
    return 1;
}

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int limit = argc > 1 ? atoi(argv[1]) : 100000;
    int local_count = 0;
    for (int n = 2 + rank; n <= limit; n += size) {
        local_count += is_prime(n);
    }

    int total_count = 0;
    MPI_Reduce(&local_count, &total_count, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    if (rank == 0) {
        printf("Found %d primes up to %d using %d MPI ranks\n", total_count, limit, size);
    }
    MPI_Finalize();
    return 0;
}
EOF

# Compile the MPI source code.
mpicc -O2 mpi_prime_sieve.c -lm -o mpi_prime_sieve

# Launch the MPI program with one rank per Slurm task.
srun -n "${SLURM_NTASKS}" ./mpi_prime_sieve 100000
```

The important Slurm resource lines are the `#SBATCH` directives near the top of the script. They request the debug partition, a small amount of time, and the CPU, memory, node, or GPU resources needed by this smoke test. The `module load` commands prepare the software environment, and `srun` is used when the application should be launched through Slurm across allocated tasks.

## Example output

After the job finishes, Slurm should report a completed job with exit code `0:0`. The job output should include a line showing how many primes were found and how many MPI ranks were used.

```text
Slurm state: COMPLETED
Exit code: 0:0
Allocated nodes: 2
Allocated CPUs: 4
Example application output: Found 9592 primes up to 100000 using 4 MPI ranks
```

For a successful run, the Slurm state should be `COMPLETED`, the exit code should be `0:0`, and the application output should report the expected four MPI ranks.
