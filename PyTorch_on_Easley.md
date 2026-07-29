## Setting Up PyTorch on Easley

### SSH in to Easley
To connect to Easley, use the secure shell command below with your username in place of $USERNAME. This will prompt you for your password. When typing your password, you will not get any visual feedback. If you have issues with connecting to the machine, please reach out to the CARC helpdesk.

```
ssh $USERNAME@easley.alliance.unm.edu
```

### Use the shared PyTorch environment

CARC maintains a shared, pre-built PyTorch conda environment, so you don't need to build your own from a wheel file. Load Miniconda and activate it:

```
module load miniconda3/latest
source activate /projects/shared/conda/envs/pytorch-2.5.1
```

Note: use `source activate`, not `conda activate`, for this. `conda activate` reliably fails on Easley/Hopper with `CondaError: Run 'conda init' before 'conda activate'`, even right after running `conda init`. `source activate` works without that step.

Your command line prompt should now show the environment name:

```
(pytorch-2.5.1)[username@easley-sn ~]$
```

### Test the installation on a GPU

Easley's GPU partitions are `h100` and `l40s` (H100 and L40S GPUs respectively) — request GPUs with `--gres=gpu:<type>:<count>`. Here's a small Slurm script requesting 2 L40S GPUs:

```
#!/bin/bash
#SBATCH --job-name gputest
#SBATCH --partition l40s
#SBATCH --gres=gpu:l40s:2
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --time 00:05:00
#SBATCH --output gputest.out
#SBATCH --error gputest.err

module load miniconda3/latest
source activate /projects/shared/conda/envs/pytorch-2.5.1
python3 -c "import torch; print(torch.cuda.device_count())"
```

Submit it with:

```
sbatch gputest.sh
```

`gputest.out` should contain:

```
2
```

### Using PyTorch through JupyterHub

Go to https://easley.alliance.unm.edu/jupyter and log in with your CARC username and password. If you are logged in without being prompted to select a server, click on the control panel button in the upper right corner, select "Stop My Server", then "Start Server".

You will be prompted to choose a server. Choose an Easley server with the GPU count you need, for example:

```
Easley, 1 hour, 2 GPUs (l40s), 16 cores, 60 GB RAM
```

Create a new notebook selecting the pytorch-2.5.1 environment from the kernel list, then run:

```
import torch
torch.cuda.device_count()
```

With 2 GPUs requested, you should get:

```
2
```

### Building your own environment instead

If you need a different PyTorch version or extra packages the shared environment doesn't have, create your own:

```
module load miniconda3/latest
conda create -n my-pytorch-env python=3.11 pytorch torchvision pytorch-cuda -c pytorch -c nvidia -y
```

Then activate it the same way as above, with `source activate my-pytorch-env`.
