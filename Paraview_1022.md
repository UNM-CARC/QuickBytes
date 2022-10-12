# Remote Visualization using ParaView in parallel.

ParaView is an open-source, multi-platform data analysis and visualization application. ParaView users can quickly build visualizations to analyze their data using qualitative and quantitative techniques. The data exploration can be done interactively in 3D or programmatically using ParaView's batch processing capabilities.

ParaView was developed to analyze extremely large datasets using distributed memory computing resources. It can be run on supercomputers to analyze datasets of petascale size.

These steps will help you setup Paraview to work as a client/server mode, being your laptop/desktop computer a client and the cluster a server. Be sure that the ParaView version installed on your local computer matches the same one that is installed on Wheeler, Gibbs or Hopper clusters. Hopper and Wheeler's Paraview version is 5.11.0-RC1 and Gibbs's ParaView version is 5.9.1

* Downloads: https://www.paraview.org/download/

* ParaView User's Guide: https://docs.paraview.org/en/latest/UsersGuide/index.html

* Wiki Page: https://www.paraview.org/Wiki/ParaView

## Hopper Cluster Connection Overview

The most common approach to use ParaView on Hopper is through the Client-Server mode support by ParaView, which requires an installation of ParaView on your local computer (Client). There are two methods to connect to Paraview Server (PVSERVER):

### Method 1: Direct Connection



### Method 1: Reverse Connection (--rc)


This is a two-step process, requesting a compute node via SSH and opening an SSH tunnel to Gibbs's service node.

The following examples assume you are using the Gibbs cluster.

The process to connecto to ParaView is, in one terminal you will ask Wheeler or Gibbs to give you compute nodes, where you will run the ParaView server. Once the ParaView server is listening for connections, you will open an ssh tunnel in another terminal window (This process is from your local computer to one of the compute nodes you were assigned). Then, you will tell the ParaView client on your computer to connect to the tunnel and so to the compute nodes at CARC, where it will perform the rendering.
