# Remote Visualization using ParaView in parallel.

ParaView is an open-source, multi-platform data analysis and visualization application. ParaView users can quickly build visualizations to analyze their data using qualitative and quantitative techniques. The data exploration can be done interactively in 3D or programmatically using ParaView's batch processing capabilities.

ParaView was developed to analyze extremely large datasets using distributed memory computing resources. It can be run on supercomputers to analyze datasets of petascale size.

### Overview: Paraview Connection and Documentation

The process to connecto to ParaView is, in one terminal you will ask Wheeler or Gibbs to give you compute nodes, where you will run the ParaView server. Once the ParaView server is listening for connections, you will open an ssh tunnel in another terminal window (This process is from your local computer to one of the compute nodes you were assigned). Then, you will tell the ParaView client on your computer to connect to the tunnel and so to the compute nodes at CARC, where it will perform the rendering.

_NOTE: Be sure that the ParaView version installed on your local computer matches the same one that is installed on ether Wheeler or Gibbs cluster. Gibbs's ParaView version is 5.9.1 and Wheeler's ParaView Ver. is 5.4.1._

* Downloads: https://www.paraview.org/download/

* ParaView User's Guide: https://docs.paraview.org/en/latest/UsersGuide/index.html

* Wiki Page: https://www.paraview.org/Wiki/ParaView
