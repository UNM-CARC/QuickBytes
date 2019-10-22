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
cd ~/ipython
```

Now on Jupyter hub go to the IPython Clusters tab (refresh if already open) and you should see a pbs profile now available to you. 
You can start a job by setting number of engins to 8 and clicking start under actions. Check that the job is running in terminal with 

```
watch qstat -tn -u <username>
```


### In a Jupyter notebook

```python
import ipyparallel as ipp
from mpi4py import MPI
import numpy as np
```


```python
c = ipp.Client(profile='pbs')
```


```python
view = c[:]
```


```python
view.activate() # enable magics
```


```python
status_psum_run=view.run('/users/mfricke/psum.py')
```


```python
status_psum_run.wait_interactive()
```

    
    done



```python
status_scatter=view.scatter('a',np.arange(16,dtype='float'))
```


```python
status_scatter.wait_interactive()
```

    
    done



```python
view['a']
```




    [array([0., 1.]),
     array([2., 3.]),
     array([4., 5.]),
     array([6., 7.]),
     array([8., 9.]),
     array([10., 11.]),
     array([12., 13.]),
     array([14., 15.])]




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




    [array(120.),
     array(120.),
     array(120.),
     array(120.),
     array(120.),
     array(120.),
     array(120.),
     array(120.)]




```python
status_mpi_size=%px size = MPI.COMM_WORLD.Get_size()
```


```python
status_mpi_size.wait_interactive()
```

    
    done



```python
view['size']
```




    [8, 8, 8, 8, 8, 8, 8, 8]




```python

```
