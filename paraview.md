# Remote Visualization using ParaView in parallel.

ParaView is an open-source, multi-platform data analysis and visualization application. ParaView users can quickly build visualizations to analyze their data using qualitative and quantitative techniques. The data exploration can be done interactively in 3D or programmatically using ParaView's batch processing capabilities.

ParaView was developed to analyze extremely large datasets using distributed memory computing resources. It can be run on supercomputers to analyze datasets of petascale size.

These steps will help you setup Paraview to work as a client/server mode, being your laptop/desktop computer a client and the cluster a server. Be sure that the ParaView version installed on your local computer matches the same one that is installed on Wheeler and Hopper clusters.

To see a current list of paraview versions installed on CARC clusters login to the cluster and run

    module spider paraview

* Downloads: https://www.paraview.org/download/
* ParaView User's Guide: https://docs.paraview.org/en/latest/UsersGuide/index.html

## Hopper Cluster Connection

The most common approach to use ParaView on Hopper is through the Client-Server mode support by ParaView, which requires an installation of ParaView on your local computer (Client). There are two methods to connect to Paraview Server (PVSERVER):

### Method 1: Direct Connection (Off-Campus)

The process to connecto to ParaView is, in one terminal you will ask Hopper to assign you compute nodes, where you will run the ParaView server. Once the ParaView server is listening for connections, you will open an ssh tunnel in another terminal window (This process is from your local computer to one of the compute nodes you were assigned). Then, you will tell the ParaView client on your computer to connect to the tunnel and so to the compute nodes at CARC, where it will perform the rendering.

#### Terminal 1: Login to Hopper and allocate resources

#### 1. Login to Hopper

    ssh username@hopper.alliance.unm.edu
  
#### 2. Allocating 2 nodes : Total 64 cores for 30 minutes in the "General" queue/partition.

    salloc --nodes 1 --exclusive --partition general --time 00:30:00

#### 3. Load Module

    module load paraview/5.11.1

#### 4. Running pvserver (this command will allow a connection between your local computer and Hopper).

    mpiexec -np 32 pvserver --mpi --force-offscreen-rendering --server-port=11111

#### Terminal 2: Hopper SSH Tunneling
The hopper### corresponds to the compute node allocated by slurm, and do not forget to change your username. 

    ssh -L 11111:hopper###:11111 username@hopper.alliance.unm.edu

#### ParaView 5.11.1 Client and Setup Server Configuration

1. File --> Connect 
2. On the "Choose Server Configuration" window: 
* Click on "Add Server"
* Name: Hopper
* Server Type: "Client / Server"
* Host: localhost
* Port: 11111

3. Click on "Configure"
4. Startup Type: Manual
5. Click on "Save"

_Note: To Verify, Client - Server setup, go to "View" and select "Memory Inspector"_

NOTE: When you are finished make sure to end the interactive job on the compute nodes. You can do this by exiting "Exit" the compute node or the "scancel" command on the cluster head node.

### Method 2: Reverse Connection (UNM On-Campus)

This process allows you to connect to Hopper service node. This process requires to know your localhost IP address "local_host_IP". Check your firewall setting if you are having firewall connectivity issues.

#### Terminal 1: Login to Hopper and allocate resources

#### 1. Login to Hopper

    ssh username@hopper.alliance.unm.edu
  
#### 2. Allocating 1 node : Total 32 cores for 30 minutes in the "General" queue/partition.

    salloc --nodes 1 --exclusive --partition general --time 00:30:00

#### 3. Load Module

    module load paraview/5.11.1

#### 4. Running pvserver (this command will allow a connection between your local computer and Hopper).

    mpiexec -np 32 pvserver --mpi --force-offscreen-rendering --rc --client-host=My_Public_IP

#### Opening ParaView 5.11.1 Client and Setup Server Configuration

Note: To Verify, Client - Server setup, go to "View" and select "Memory Inspector"

1. File --> Connect
2. On the "Choose Server Configuration" window:
* Click on "Add Server"
* Name: Hopper RC
* Server Type: "Client / Server (Reverse Connection)"
* Host: localhost
* Port: 11111

3. Click on "Configure"
4. Startup Type: Manual
5. Click on "Save"

NOTE: When you are finished make sure to end the interactive job on the compute nodes. You can do this by exiting "Exit" the compute node or the "scancel" command on the cluster head node.

## ParaView executables
ParaView comes with several executables that serve different purposes. These are: paraview, pvpython, pvbatch, pvserver, pvdataserver and pvrenderserver. To learn more about this executables, https://docs.paraview.org/en/latest/UsersGuide/introduction.html#paraview-executables. 