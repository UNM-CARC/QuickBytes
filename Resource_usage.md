# Storage Policy

Home directories are limited to 200 GB of storage. Project space is limited to 250 GB of storage. Scratch storage is limited to 1 TB (2 TB on Xena). Center-wide project scratch space is limited to 3 TB. To purchase additional storage please see our [pricing spreadsheet](https://carc.unm.edu/research/premium-research-computing-services.html).

# Resource Usage Policy

Soft limits and hard limits are used to provide fair scheduling without wasting resources. The job scheduler will schedule all jobs meeting the soft limit requirements. If there are additional resources after all jobs meeting the soft limits are scheduled, then jobs meeting the hard limits are scheduled. The hard limits prevent users from monopolising the cluster for long periods by starting large jobs during temporary lulls in utilisation. 

## Xena Configuration

| Queue | GPU | GPU | Bigmem | Bigmem | Debug | Debug |
|---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Parameter | soft limit | hard limit | soft limit | hard limit | soft limit | hard limit |
| Number of Processors | 64 | 192 | 64 | 128 | 4 | 4 |
| Number of Nodes | 4 (singleGPU) <br> 4 (dualGPU) | 12 (singleGPU) <br> 4 (dualGPU) | 2 | 2 | 1 | 1 |
| Processors per Node | 16 | 16 | 32 | 32 | 4 | 4 |
| Walltime(H:M:S) | 48:00:00 | 48:00:00 | 48:00:00 | 48:00:00 | 04:00:00 | 04:00:00 |


## Wheeler Configuration


|                Queue: |   Default  |   Default  |    Debug   |   Debug    |
|----------------------:|:----------:|:----------:|:----------:|:----------:|
|             Parameter | soft limit | hard limit | soft limit | hard limit |
| Number of Processors  |     160    |     400    |     32     |     32     |
|      Number of Nodes  |     20     |     50     |      4     |      4     |
|   Processors per Node |      8     |      8     |      8     |      8     |
|       Walltime(H:M:S) |  48:00:00  |  48:00:00  |  04:00:00  |  04:00:00  |



## Gibbs Configuration

Parameters |	Soft Limit  |	Hardlimit
--- | --- | ---
Number of Processors |	96 |	96
Number of Nodes	|6 | 6
Processors per Node |	16  | 16
Walltime(H:M:S) |  96:00:00  | 96:00:00

## Hopper Configuration
TBD
