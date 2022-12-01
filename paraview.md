# How to: Remote Visualization using ParaView in parallel.

ParaView is an open-source, multi-platform data analysis and visualization application. ParaView users can quickly build visualizations to analyze their data using qualitative and quantitative techniques. The data exploration can be done interactively in 3D or programmatically using ParaView's batch processing capabilities.

ParaView was developed to analyze extremely large datasets using distributed memory computing resources. It can be run on supercomputers to analyze datasets of petascale size.

### Overview: Paraview Connection and Documentation

The process to connecto to ParaView is, in one terminal you will ask Wheeler or Gibbs to give you compute nodes, where you will run the ParaView server. Once the ParaView server is listening for connections, you will open an ssh tunnel in another terminal window (This process is from your local computer to one of the compute nodes you were assigned). Then, you will tell the ParaView client on your computer to connect to the tunnel and so to the compute nodes at CARC, where it will perform the rendering.

**_NOTE: Be sure that the ParaView version installed on your local computer matches the same one that is installed on ether Wheeler or Gibbs cluster. Gibbs's ParaView version is 5.9.1, Wheeler's version is 5.11.0-RC1 and for Hopper Cluster Information, [click here.](https://github.com/UNM-CARC/QuickBytes/blob/master/Paraview_Hopper.md)_ 

* Downloads: https://www.paraview.org/download/

* ParaView 4.9.1 Guide: https://docs.paraview.org/en/v5.9.1/
* Paraview 5.11.0-RC1 Guide: https://docs.paraview.org/en/v5.11.0/UsersGuide/index.html

* Wiki Page: https://www.paraview.org/Wiki/ParaView


## Method 1: Client - Server Mode (Gibbs Direct Connection)

The most common approach to use ParaView on Gibbs is through the Client-Server mode support by ParaView, which requires an installation of ParaView on your local computer. This is a two-step process, requesting a compute node via SSH and opening an SSH tunnel to Gibbs's service node.

The following examples assume you are using the Gibbs cluster.

### Terminal 1: SSH to Gibbs

Accessing Gibbs and requesting one nodes with four cores. _NOTE: Wait until Gibbs assigns you a compute node._

```bash
ssh username@gibbs.alliance.unm.edu

qsub -I -l nodes=1:ppn=4
```

#### Loading ParaView Module 5.9.1 in Gibbs

```bash
module load paraview/5.9.1
```

#### Run ParaView PVServer on Compute Nodes

```bash
mpiexec -np 4 pvserver --mpi --use-offscreen-rendering --server-port=11111
```

### Terminal 2: SSH Tunnel to a Gibbs Compute node
_Note: this step is from your local computer to Gibbs's compute node._ 

Make sure to replace the "compute_node_name" from the bash command below to one of the compute nodes you were assigned by qsub. Example "gibbs18" or "gibbs20".

```bash
ssh -L 11111:compute_node_name:11111 username@gibbs.alliance.unm.edu
```

### Opening ParaView 5.9.1 and Setup Server Configuration

1. File --> Connect 
2. On the "Choose Server Configuration" window: 
* Click on "Add Server"
* Name: Gibbs
* Server Type: "Client / Server"
* Port: 11111

3. Click on "Configure"
4. Startup Type: Manual
5. Click on "Save"

_Note: To Verify, Client - Server setup, go to "View" and select "Memory Inspector"_

NOTE: When you are finished make sure to end the interactive job on the compute nodes. You can do this by exiting "Exit" the compute node or the qdel command on the cluster head node.



## Method 2: Client - Server Mode (Wheeler: Reverse Connection) 

This process allows you to connect to wheeler service node. This process requires to know your localhost IP address "local\_host_IP". Check your firewall setting if you are having firewall connectivity issues. 

### Terminal 1: SSH to Wheeler

Accessing Wheeler and requesting 2 nodes with 8 cores each.

```bash
ssh username@wheeler.alliance.unm.edu
qsub -I -l nodes=2:ppn=8
```

NOTE: Wait until wheeler assigns you two compute nodes.

#### Load ParaView Module

```bash
module load paraview/5.11.0-RC1
```

#### Run ParaView PVServer on the Compute Nodes

```bash
mpiexec -np 16 pvserver --mpi --force-offscreen-rendering --rc --client-host=local_host_IP
```

### Opening ParaView 5.4.1 and Setup Server Configuration
_Note: To Verify, Client - Server setup, go to "View" and select "Memory Inspector"_

1. File --> Connect 
2. On the "Choose Server Configuration" window: 
* Click on "Add Server"
* Name: Wheeler RC
* Server Type: "Client / Server (Reverse Connection)"
* Port: 11111

3. Click on "Configure"
4. Startup Type: Manual
5. Click on "Save"

NOTE: When you are finished make sure to end the interactive job on the compute nodes. You can do this by exiting "Exit" the compute node or the qdel command on the cluster head node.
