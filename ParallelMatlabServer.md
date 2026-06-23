# Parallel MATLAB Server

## Overview

MATLAB supports parallelization on desktop computers through the Parallel Computing Toolbox, which can significantly speed up computation.

MATLAB also provides MATLAB Parallel Server (formerly MATLAB Distributed Computing Server), which allows you to run MATLAB code locally while offloading computation to CARC high-performance computing clusters.

This QuickByte explains how to configure and use MATLAB Parallel Server with CARC systems.

If you run into issues, contact: [help@carc.unm.edu](mailto:help@carc.unm.edu)

> Ensure that the MATLAB version on your local machine matches the version installed on the CARC cluster.

---

## How MATLAB Parallel Server Works

MATLAB Parallel Server connects your local MATLAB session (the client) to the CARC cluster scheduler.

* The MATLAB client runs on your local machine
* The cluster scheduler (Slurm at CARC) manages job submission
* Workers are launched on compute nodes
* Each worker executes part of your MATLAB computation

At CARC:

* Slurm is used for scheduling
* All computation runs on compute nodes
* Login/head nodes must not be used for computation

You can scale computations by requesting multiple workers, each of which runs a portion of your workload.

---

## MATLAB Parallel Server Client Configuration

Before starting:

* Install MATLAB on your local machine
* Install MATLAB Parallel Computing Toolbox
* Install the "Parallel Computing Toolbox plugin for MATLAB Parallel Server with Slurm"
* Ensure your MATLAB version matches the CARC module

### Installing the Plugin

1. Open MATLAB
2. Click **Add-Ons → Get Add-Ons**
3. Search for:

   * "Parallel Computing Toolbox plugin for MATLAB Parallel Server with Slurm"
4. Click **Install**
5. The cluster configuration wizard will start automatically

---

### Cluster Type Configuration

In the wizard:

* Select **UNIX** as cluster type
* Select **Slurm** as scheduler
* Select **No shared job folder**

---

### Cluster Connection Settings

Enter:

* Cluster address:

  * `easley.alliance.unm.edu`
* Remote job storage location:

  * `/users/yourUsername/`
* Select:

  * **Unique subfolders**

---

### Workers Configuration

* Number of workers: depends on workload
* Threads per worker: usually 1

For initial setup and validation:

* Set workers = 1
* Set threads per worker = 1

Each worker corresponds to one CPU core.

---

### Remote MATLAB Path

Specify the MATLAB installation path on the cluster.

This corresponds to the MATLAB module path on CARC systems. Check `module avail matlab` on the cluster to confirm the path and version available.

Make sure the local and cluster MATLAB versions match.

---

### License Configuration

* Choose **FlexNet license**

---

### Profile Setup

* Name your profile (example):

  * `Easley_Slurm`

You can create multiple profiles for different CARC systems or configurations.

---

### Complete Setup

Review settings and finish the wizard.

You can also run:

```matlab
parallel.cluster.generic.runProfileWizard()
```

---

## Setting Your IP Address

MATLAB must know your local machine IP so the cluster can communicate with your MATLAB client.

### macOS

```matlab
[~,name] = system('ipconfig getifaddr en0');
pctconfig('hostname', strtrim(name));
```

### Linux

```matlab
[~,name] = system('hostname -i');
pctconfig('hostname', strtrim(name));
```

### Windows 10

Manually find your IP address and run:

```matlab
pctconfig('hostname', "<your IP address>");
```

---

## Validating the Configuration

1. Open MATLAB
2. Go to:

   * Parallel → Create and Manage Clusters
3. Select your configured profile
4. Open the **Validation** tab
5. Click **Validate**

You will be prompted for:

* CARC username
* Password or SSH key (optional)

After validation completes successfully:

* Restart MATLAB (recommended)

---

## Writing Parallel MATLAB Code

Once configured, you can use `parfor` to distribute work across workers.

### Example: Simple Parallel Loop

```matlab
n_workers = 10;

p = parpool('easley', n_workers);

parfor i = 1:100
    disp(i)
end

delete(p);
```

This:

* Opens a pool of workers on CARC compute nodes
* Distributes loop iterations across workers
* Closes the pool after completion

---

## Monitoring MATLAB Jobs

Log into CARC:

```bash
ssh yourUsername@easley.alliance.unm.edu
```

Check running jobs:

```bash
squeue -u yourUsername
```

Monitor continuously:

```bash
watch squeue -u yourUsername
```

---

## Writing Test Files

### Example MATLAB script

```bash
nano test_parallel.m
```

```matlab
parpool('easley', 4);

parfor i = 1:20
    disp(i)
end

delete(gcp('nocreate'));
```

---

### Example input file

```bash
nano input.txt
```

```text
1
2
3
4
5
```

---

## Debugging Commands

### File and environment checks

```bash
pwd
```

Show current directory (important when submitting from home directory).

```bash
ls -lh
```

List files and confirm scripts exist.

```bash
module avail matlab
```

Check available MATLAB versions.

```bash
module load matlab
```

Load MATLAB environment on the cluster.

---

### Slurm job monitoring

```bash
squeue -u yourUsername
```

Check running jobs.

```bash
scancel yourJobId
```

Cancel a job.

```bash
scontrol show job yourJobId
```

Detailed job information.

---

### MATLAB execution debugging

```bash
matlab -batch "my_program"
```

Run MATLAB script in batch mode.

```bash
matlab -batch "my_program" > matlab.output
```

Save MATLAB output.

---

### Interactive compute debugging

```bash
srun --pty bash
```

Start an interactive session on a compute node.

```bash
module load matlab
matlab -batch "my_program"
```

Run MATLAB interactively on a compute node.

---

### Parallel Server troubleshooting

```matlab
parallel.cluster.generic.clusterProfileList
```

List available cluster profiles.

```matlab
delete(gcp('nocreate'))
```

Close the active parallel pool.

---

*This QuickByte was validated on 6/23/2026.*
