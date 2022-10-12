# Remote Visualization using ParaView in parallel.

ParaView is an open-source, multi-platform data analysis and visualization application. ParaView users can quickly build visualizations to analyze their data using qualitative and quantitative techniques. The data exploration can be done interactively in 3D or programmatically using ParaView's batch processing capabilities.

ParaView was developed to analyze extremely large datasets using distributed memory computing resources. It can be run on supercomputers to analyze datasets of petascale size.

These steps will help you setup Paraview to work as a client/server mode, being your laptop/desktop computer a client and the cluster a server. Be sure that the ParaView version installed on your local computer matches the same one that is installed on Wheeler, Gibbs or Hopper clusters. 
*NOTE: Hopper and Wheeler's Paraview version is 5.11.0-RC1 and Gibbs's ParaView version is 5.9.1*

* Downloads: https://www.paraview.org/download/
* ParaView User's Guide: https://docs.paraview.org/en/latest/UsersGuide/index.html
* Wiki Page: https://www.paraview.org/Wiki/ParaView

## Hopper Cluster Connection

The most common approach to use ParaView on Hopper is through the Client-Server mode support by ParaView, which requires an installation of ParaView on your local computer (Client). There are two methods to connect to Paraview Server (PVSERVER):

### Method 1: Direct Connection

The process to connecto to ParaView is, in one terminal you will ask Hopper to assign you compute nodes, where you will run the ParaView server. Once the ParaView server is listening for connections, you will open an ssh tunnel in another terminal window (This process is from your local computer to one of the compute nodes you were assigned). Then, you will tell the ParaView client on your computer to connect to the tunnel and so to the compute nodes at CARC, where it will perform the rendering.

#### Terminal 1: Login to Hopper and allocate resources

#### 1. Login to Hopper
```bash
  ssh username@hopper.alliance.unm.edu
```  
#### 2. Allocating 2 nodes : Total 64 cores for 30 minutes in the "General" queue/partition.

```bash
salloc --nodes 2 --exclusive --partition general --time 00:30:00
```

#### 3. Load Module
```bash
module load paraview/5.11.0-RC1
```

#### 4. Running pvserver (this command will allow a connection between your local computer and Hopper).
```bash
mpiexec -np 64 pvserver --mpi --force-offscreen-rendering --server-port=11111
```

#### Terminal 2: Hopper SSH Tunneling
The hopper### corresponds to the compute node allocated by slurm, and do not forget to change your username. 

```bash
ssh -L 11111:hopper###:11111 username@hopper.alliance.unm.edu
```

#### ParaView 5.11.0 RC1 Client and Setup Server Configuration

1. File --> Connect 
2. On the "Choose Server Configuration" window: 
* Click on "Add Server"
* Name: Hopper
* Server Type: "Client / Server"
* Port: 11111

3. Click on "Configure"
4. Startup Type: Manual
5. Click on "Save"

_Note: To Verify, Client - Server setup, go to "View" and select "Memory Inspector"_

NOTE: When you are finished make sure to end the interactive job on the compute nodes. You can do this by exiting "Exit" the compute node or the "scancel" command on the cluster head node.

### Method 2: Reverse Connection (--rc)

This process allows you to connect to Hopper service node. This process requires to know your localhost IP address "local_host_IP". Check your firewall setting if you are having firewall connectivity issues.

#### Terminal 1: Login to Hopper and allocate resources

#### 1. Login to Hopper
```bash
  ssh username@hopper.alliance.unm.edu
```  
#### 2. Allocating 2 nodes : Total 64 cores for 30 minutes in the "General" queue/partition.

```bash
salloc --nodes 2 --exclusive --partition general --time 00:30:00
```

#### 3. Load Module
```bash
module load paraview/5.11.0-RC1
```

#### 4. Running pvserver (this command will allow a connection between your local computer and Hopper).
```bash
mpiexec -np 64 pvserver --mpi --force-offscreen-rendering --rc --client-host=My_Public_IP
```

#### Opening ParaView 5.11.0 RC1 Client and Setup Server Configuration

Note: To Verify, Client - Server setup, go to "View" and select "Memory Inspector"

    1. File --> Connect
    2. On the "Choose Server Configuration" window:

    * Click on "Add Server"
    * Name: Hopper RC
    * Server Type: "Client / Server (Reverse Connection)"
    * Port: 11111

    3. Click on "Configure"
    4. Startup Type: Manual
    5. Click on "Save"

NOTE: When you are finished make sure to end the interactive job on the compute nodes. You can do this by exiting "Exit" the compute node or the "scancel" command on the cluster head node.

## pvserver vs. pvrenderserver & pvdataserver

There are two modes in which you can launch the ParaView server. In the first mode, all data processing and rendering are handled in the same parallel job. This server is launched with the pvserver command. In the second mode, data processing is handled in one parallel job and the rendering is handled in another parallel job launched with the pvdataserver and pvrenderserver programs, respectively.

The point of having a separate data server and render server is the ability to use two different parallel computers, one with high performance CPUs and the other with GPU hardware. However, the server functionality split in two necessitates repartitioning and transfering the data from one to the other. This overhead is seldom much smaller than the cost of just performing both data processing and rendering in the same job.

Thus, we recommend on almost all instances simply using the single pvserver. This document does not describe how to launch data server / render server jobs. Even if you really feel like this mode is right for you, it is best to first to configure your server in single server mode. From there, establishing the data server / render server should be easier. 

Setting up ParaView Server, [Click Here.](https://www.paraview.org/Wiki/Setting_up_a_ParaView_Server) and If you would like to run paraview without a GUI interface, you can use the "pvpython" instead of pvserver https://www.paraview.org/Wiki/PvPython_and_PvBatch
