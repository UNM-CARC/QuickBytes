# Storage Policy

Home directories are limited to 100 GB soft / 200 GB hard quota. Scratch storage (`/easley/scratch` on Easley) has no personal per-user quota enforced. To purchase additional storage please see our [pricing spreadsheet](https://carc.unm.edu/research/premium-research-computing-services.html).

# Resource Usage Policy

Slurm schedules jobs against per-user resource limits set on each partition's QOS (Quality of Service). These limits cap how much CPU, memory, and GPU a single user can have allocated at once on a given partition, so no one user can monopolize a partition and starve everyone else's jobs.

## Easley Configuration

| Partition | Max CPUs/User | Max Memory/User | GPUs/User | Walltime |
| --- | --- | --- | --- | --- |
| general (default) | 512 | ~2 TB | - | 2-00:00:00 |
| bigmem | 64 | ~2 TB | - | 2-00:00:00 |
| h100 | 64 | ~1 TB | 2 | 2-00:00:00 |
| l40s | 96 | ~168 GB | 3 | 2-00:00:00 |
| interactive | 64 | ~250 GB | 1 (on GPU nodes) | 04:00:00 |
| debug | 128 | ~500 GB | 2 (on GPU nodes) | 01:00:00 |

Node Access Policy | Multiple users' jobs can share the same compute node, allocated by CPU/memory rather than whole nodes.
--- | ---

## Hopper Configuration

| Partition | Max CPUs/User | Max Memory/User | Walltime |
| --- | --- | --- | --- |
| general (default) | 128 | ~380 GB | 2-00:00:00 |
| debug | 8 | 25 GB | 04:00:00 |

Node Access Policy | Multiple users' jobs can share the same compute node, allocated by CPU/memory rather than whole nodes.
--- | ---

*This quickbyte was validated on 7/30/2026*
