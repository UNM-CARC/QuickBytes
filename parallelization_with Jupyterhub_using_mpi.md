## Parallelization with Jupyter hub using MPI

The following steps will show you the steps to use mpi through ipython to parallelize your code. 

### Create a pbs profile on carc 

Once you are logged in at carc run these steps:

```
cd /projects/systems/shared
cp -r profile_pbs ~/.python/
```

Then check the files copied. 

```
cd ~/ipython/profile_pbs
```

Now on Jupyter hub go to the IPython Clusters tab (refresh if already open) and you should see a pbs profile now available to you. 
You can start a job by setting number of engines to 8 and clicking start under actions. Check that the job is running in terminal with 

```
watch qstat -tn -u <username>
```

To exit the watch command use control c 

To change the walltime of your profile, in the ~/.ipython/profile_pbs directory edit the pbs.engine.template and the pbs.controller.template to fit the requirments for your job. By editing these files you can also change from the default to debug queue as you are testing your program. 

Now you can open a Jupyter notebook and follow this tutorial. 

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


```python
#status_psum_run=view.run('psum.py')
```

status_psum_run.wait_interactive()


```python
%px with view.sync_imports():
```




    <AsyncResult: execute>



## Define the psum function on all nodes


```python
def psum(a):
    locsum = np.sum(a)
    rcvBuf = np.array(0.0,'d')
    MPI.COMM_WORLD.Allreduce([locsum, MPI.DOUBLE],
        [rcvBuf, MPI.DOUBLE],
        op=MPI.SUM)   
    return rcvBuf
```

## Send data to all nodes to by summed


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




```python
status_execute=view.execute('totalsum_exec=psum(a)')
```


```python
status_psum_call.wait_interactive()
```

   
    done



```python
view['totalsum_exec']
```




    [array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.),
     array(496.)]




```python

```


```python

```
