# Storage Policy

Home directories are limited to 200 GB of storage. Project space is limited to 250 GB of storage. Scratch storage is limited to 1 TB (2 TB on Xena). Center-wide project scratch space is limited to 3 TB. To purchase additional storage please see our [pricing spreadsheet](https://carc.unm.edu/research/premium-research-computing-services.html).

# Resource Usage Policy

Soft limits and hard limits are used to provide fair scheduling without wasting resources. The job scheduler will schedule all jobs meeting the soft limit requirements. If there are additional resources after all jobs meeting the soft limits are scheduled, then jobs meeting the hard limits are scheduled. The hard limits prevent users from monopolising the cluster for long periods by starting large jobs during temporary lulls in utilisation. 

## Xena Configuration

Parameters |	Soft Limit  |	Hardlimit
--- | --- | ---
Number of Processors |	64 |	128
Number of Nodes	|4 (xena) <br> 2(BigMem) |  8 (xena) <br> 4 (Bigmem)
Processors per Node |	16(xena) <br> 32(BigMem)  | 16 (xena) <br>  32 (BigMem)


Node Access Policy |	Single Job/Node ie (Multiple users can’t share resources across same node)
--- | ---



## Wheeler Configuration


|                Queue: |   Default  |   Default  |    Debug   |   Debug    |
|----------------------:|:----------:|:----------:|:----------:|:----------:|
|             parameter | soft limit | hard limit | soft limit | hard limit |
| Number of Processors  |     160    |     400    |     32     |     32     |
|      Number of Nodes  |     20     |     50     |      4     |      4     |
|   Processors per Node |      8     |      8     |      8     |      8     |
|              Walltime |  48:00:00  |  48:00:00  |  01:00:00  |  01:00:00  |

Node Access Policy | Multi Job/Node ie (Multiple users may share resources across same node)
--- | ---



## Gibbs Configuration

Parameters |	Soft Limit  |	Hardlimit
--- | --- | ---
Number of Processors |	96 |	96
Number of Nodes	|6 | 6
Processors per Node |	16  | 16

Node Access Policy |	Single Job/Node ie (Multiple users can’t share resources across same node)
--- | ---
