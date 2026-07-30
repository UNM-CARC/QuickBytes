## Parallelization with JupyterHub using MPI

The following steps will show you the steps to use MPI through ipython's ipyparallel interface. 

### Create a Slurm profile on CARC 

Once you are logged in at carc run these steps:

```console
ipython profile create --parallel --profile=slurm
```

Edit `~/.ipython/profile_slurm/ipcontroller_config.py` and add the following line. This tells the controller to listen on all network interfaces, not just localhost — without it, engines launched on a separate compute node from the controller can't connect back, and will fail with a "controller and engines are not on the same machine" error:

```python
c.IPController.ip = "0.0.0.0"
```

Then start the cluster, requesting however many engines you want (8 in this example):

```console
ipcluster start --profile=slurm --engines=Slurm -n 8
```

[Optional] Since this is requesting compute nodes through Slurm, you will have to wait until the nodes are running before you can run 
code on them. Check that the job is running in terminal with 

```console
watch squeue -u <username>
```

You should see something like the following:

```
Every 2.0s: squeue -u hfricke     Wed Jul 29 12:47:37 2026

 JOBID  PARTITION     NAME     USER ST   TIME  NODES NODELIST(REASON)
1034174   general  ipengine  hfricke  R  00:33      1  easley048
```

Notice the ipengine job is running with status 'R'. You can also check to see whether the compute engines are ready in your python notebook (see below).

To exit the watch command use control-C 

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

## Create a cluster to use the CPUs allocated through Slurm


```python
cluster = ipp.Client(profile='slurm')
```

## Check if the cluster is ready. We are looking for 8 ids since we asked for 8 engines.

Engines in ipyparallel parlance are the same as processes or workers in other parallel systems.


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

Note we are running the Get_size command on each engine to make sure they all see the same MPI comm world. %px simply executes the code following it on each compute engine in parallel.


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

done

## Send data to all nodes to by summed
The scatter command sends 32 values from 0 to 31 to the 8 compute engines. Each compute engine gets 32/8=4 values. This is the ipyparallel scatter command, not an MPI scatter command.
```python
status_scatter=view.scatter('a',np.arange(32,dtype='float'))
```
done

We can view the variable 'a' on all the compute engines. The value of 'a' for each compute engine is an element of the return array. In this case each value is itself an array.

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

## Execute the psum function on all the compute engines and store the result in totalsum
MPI code has to be executed on each compute engine so they can each perform the MPI reduce. This is accomplished by calling the psum function on all the compute engines simultaneously. MPI will allow them to communicate with each other to calculate the sum. 
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

## Defining functions in the notebook
Rather than loading psum from file we can define it in the notebook using the ipython function decorator '@'. 

```python
@view.remote(block = True)
def inlinesum():
    from mpi4py import MPI
    import numpy as np
    locsum = np.sum(a)
    rcvBuf = np.array(0.0,'d')
    MPI.COMM_WORLD.Allreduce([locsum, MPI.DOUBLE],
        [rcvBuf, MPI.DOUBLE],
        op=MPI.SUM)    
    return rcvBuf
```

Now we can call inlinesum and it is automatically run on every compute engine. The call is through ipyparallels but the computation is still using MPI.

```python
inlinesum()
```
 [array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.)]
