# How to: Remote Visualization using ParaView 5.4.1 in parallel.

ParaView is an open-source, multi-platform data analysis and visualization application. ParaView users can quickly build visualizations to analyze their data using qualitative and quantitative techniques. The data exploration can be done interactively in 3D or programmatically using ParaView's batch processing capabilities.

ParaView was developed to analyze extremely large datasets using distributed memory computing resources. It can be run on supercomputers to analyze datasets of petascale size.

## ParaView 5.4.1 OpenGL

* Downloads & Documentation: https://www.paraview.org/download/

* Wiki Page: https://www.paraview.org/Wiki/ParaView

NOTE: Be sure that the paraview client installed on your machine is the same version that is installed on the CARC cluster you are using.

## Client - Server Methods

The most common approach to use ParaView on Wheeler is through the Client-Server mode support by ParaView, which requires an installation of ParaView on your local machine. This is a two-step process, requesting a compute node via SSH and creating an SSH tunnel to Wheeler's service node.

### Overview

In one terminal you will ask Wheeler to give you compute nodes where you will run the paraview server. Once the paraview server is listening for connections you will create an ssh tunnel in another terminal from your machine to one of the compute nodes you were assigned. Then you will tell the paraview client on your machine to connect to the tunnel and so to the compute nodes at CARC, where it will perform the rendering.

The following examples assume you are using the Wheeler cluster.

### Terminal 1: SSH to Wheeler

Accessing Wheeler and requesting 2 nodes with 8 cores each.

```bash
ssh username@wheeler.alliance.unm.edu

qsub -I -l nodes=2:ppn=8
```

NOTE: Wait until wheeler assigns you two compute nodes.

### Load ParaView Module

```bash
module load paraview-5.4.1-gcc-4.8.5-python2-impi-wulnuwu
```

### Run ParaView PVServer on Compute Nodes

```bash
mpirun -n 16 pvserver --use-offscreen-rendering --server-port=11111
```

### Terminal 2: SSH Tunnel to a Wheeler Compute node

From local machine to wheeler's compute node. Use the name of one of the compute nodes you were assigned by qsub above.

```bash
ssh -L 11111:compute_node_name:11111 username@wheeler.alliance.unm.edu
```

### Opening ParaView 5.4.1 and Setup Server Configuration

File --> Connect (Choose Server Configuration)

Click on "Add Server"

Name: Wheeler
Server Type: "Client / Server"
Host: localhost
Port: 11111

Click on "Configure"

Startup Type: Manual

Click on "Save"

Note: To Verify, Client - Server setup, go to "View" and select "Memory Inspector"

NOTE: When you are finished make sure to end the interactive job on the compute nodes. You can do this with the qdel command on the cluster head node.

## Client - Server Mode (Reverse Connection Method)

This process allows you to connect to wheeler service node if you have firewall connectivity issues and requires you to know your localhost IP address "local\_host_IP".

### Terminal 1: SSH to Wheeler

Accessing Wheeler and requesting 2 nodes with 8 cores each.

```bash
ssh username@wheeler.alliance.unm.edu
qsub -I -l nodes=2:ppn=8
```

NOTE: Wait until wheeler assigns you two compute nodes.

### Load ParaView Module

```bash
module load paraview-5.4.1-gcc-4.8.5-python2-impi-wulnuwu
```

### Run ParaView PVServer on the Compute Nodes

```bash
mpirun -n 16 pvserver --use-offscreen-rendering -rc --client-host=local_host_IP
```

### Opening ParaView 5.4.1 and Setup Server Configuration

File --> Connect (Choose Server Configuration)

Click on "Add Server"

Name: Wheeler RC
Server Type: "Client / Server (Reverse Connection)"
Port: 11111

Click on "Configure"

Startup Type: Manual

Click on "Save"

NOTE: When you are finished make sure to end the interactive job on the compute nodes. You can do this with the qdel command on the cluster head node.
