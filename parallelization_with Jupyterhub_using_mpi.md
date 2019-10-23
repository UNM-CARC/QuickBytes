## Parallelization with JupyterHub using MPI

The following steps will show you the steps to use MPI through ipython's ipyparallel interface. 

### Create a PBS profile on CARC 

Once you are logged in at carc run these steps:

```
cd /projects/systems/shared
cp -r profile_pbs ~/.ipython/
```

Then check the files copied. 

```
cd ~/.ipython/profile_pbs
```

Now on JupyterHub go to the IPython Clusters tab (refresh if already open) and you should see a pbs profile now available to you. Click the JupyterHub icon in the upper left of your screen if you can't see the clusters tab.

You can start a job by setting number of engine in the 'pbs' cluster profile and clicking start under actions. For this example we will request 8 ipython compute engines.

[Optional] Since ipython's ipyparallel system is requesting compute nodes through the torque PBS system you will have to wait until the nodes are running before you can run 
code on them. Check that the job is running in terminal with 

```
watch qstat -tn -u <username>
```

You should see something like the following:

Every 2.0s: qstat -t -n -u $USER     Wed Oct 23 09:15:14 2019                                                                                      
wheeler-sn.alliance.unm.edu:
                                                                                  Req'd       Req'd	  Elap
Job ID                  Username    Queue    Jobname          SessID  NDS   TSK   Memory      Time    S   Time
----------------------- ----------- -------- ---------------- ------ ----- ------ --------- --------- - ---------
258370.wheeler-sn.alli  mfricke     default  jupyterhub        21730     1	1	--   08:00:00 R  00:06:45
   wheeler291/1
258371.wheeler-sn.alli  mfricke     default  ipython_controll  22553     1	1	--   01:00:00 R  00:06:11
   wheeler291/2
258372.wheeler-sn.alli  mfricke     default  ipython_engine	3213     2     16	--   01:00:00 R  00:06:11
   wheeler176/0-7+wheeler175/0-7

Notice the ipython engines are running with status 'R'. You can also check to see whether the compute engines are ready in your python notebook (see below).

To exit the watch command use control-C 

To change the walltime of your profile, in the ~/.ipython/profile_pbs directory edit the pbs.engine.template and the pbs.controller.template to fit the requirments for your job. By editing these files you can also change from the default to debug queue as you are testing your program. 

Now you can open a Jupyter notebook and follow the remainder of this tutorial.

## Creating an example function that uses MPI

Create a new file in your home directory and name it psum.py. Enter the following into psum.py and save the file.

```python
from mpi4py import MPI
import numpy as np

def psum(a):
    locsum = np.sum(a)
    rcvBuf = np.array(0.0,'d')
    MPI.COMM_WORLD.Allreduce([locsum, MPI.DOUBLE],
        [rcvBuf, MPI.DOUBLE],
        op=MPI.SUM)
    return rcvBuf
```

This function performs a distributed sum over all the nodes on the MPI communications group.

## Create a Jupyter Notebook to Call Our MPI Function

Create a new Python 3 notebook in Jupyterhub and name it mpi_test.ipynb. Enter the following into cells of your notebook. Many of the commands are run on the MPI cluster and so are asynchronous. To check whether an operation has completed we check the status with ".wait_interactive()". When the status reports "done" you can move on to the next step.
 
## Load required packages for ipyparallel and MPI


```python
import ipyparallel as ipp
from mpi4py import MPI
import numpy as np
```

## Create a cluster to use the CPUs allocated thrugh PBS


```python
cluster = ipp.Client(profile='pbs')
```

## Check if the cluster is ready. We are looking for 8 ids since we asked for 8 engines.

Engines in ipparallel parlence are the same as processes or workers in other parallel systems.


```python
cluster.ids
```
    [0, 1, 2, 3, 4, 5, 6, 7]

```python
len(cluster[:])
```
    8

## Assign the engines to a variable named "view" to allow us to interact with them

```python
view = cluster[:]
```

Enable ipython `magics´. These are ipython helper functions such as %


```python
view.activate()
```

## Check to see if the MPI communication world is of the expected size. It should be size 8 since we have 8 engines.

Note we are running the Get_size command on each engine to make sure they all see the same MPI comm world


```python
status_mpi_size=%px size = MPI.COMM_WORLD.Get_size()
```


```python
status_mpi_size.wait_interactive()
```

   
    done


The output of viewing the size variable should be an array with the same number of entries as engines, and each entry should be the number of engines requested.


```python
view['size']
```
    [8, 8, 8, 8, 8, 8, 8, 8]
    
## Run the external python code in ´psum.py´ on all the engines.
Recall that psum.py just loads the MPI libraries and defines the distributed sum function, psum. We are not actually calling the psum function yet.

```python
status_psum_run=view.run('psum.py')
```
```python
status_psum_run.wait_interactive()
```
```python
done
```

## Send data to all nodes to by summed
The scatter command sends 32 values from 0 to 31 to the 8 compute engines. Each compute engine gets 32/8=4 values. This is the ipyparallel scatter command, not an MPI scatter command.
```python
status_scatter=view.scatter('a',np.arange(32,dtype='float'))
```

```python
status_scatter.wait_interactive()
```   
    done

```python
view['a']
```
    [array([0., 1., 2., 3.]),
     array([4., 5., 6., 7.]),
     array([ 8.,  9., 10., 11.]),
     array([12., 13., 14., 15.]),
     array([16., 17., 18., 19.]),
     array([20., 21., 22., 23.]),
     array([24., 25., 26., 27.]),
     array([28., 29., 30., 31.])]

```python
status_psum_call=%px totalsum = psum(a)
```

```python
status_psum_call.wait_interactive()
```   
    done

## Check the value of totalsum on each node
Total should be equal to 31(31+1)/2=496

```python
view['totalsum']
```

    [array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.)]

Each compute engine calculated the sum of all the values. Since we ran this MPI function on all the compute engines they report the same value.
