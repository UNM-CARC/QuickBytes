## Example of Parallelization with JupyterHub using Dask and SciKit-learn

[Dask](https://dask.org/) uses existing Python APIs and data structures to make it easy to switch between Numpy, Pandas, Scikit-learn to their Dask-powered equivalents. [SciKit-learn](https://scikit-learn.org/stable/) is a machine learning tool for Python.

### Log in to JupyterHub

Open an internet browser and go to https://easley.alliance.unm.edu/jupyter or https://hopper.alliance.unm.edu/jupyter where you will be asked to log in. Use your carc username and password. This logs you into a compute node where your programs in Jupyter notebook will be running. Because it is beginning an interactive job it may not be instant depending on resources available at the time. Once logged in, you can see all the files in your home directory. 

To be kind to other users when you are finished with JupyterHub for the day, please be sure to go to "control panel" in the top righthand corner and click "stop my server". This will free up the node for other users. Otherwise, the default walltime is 12 hours. 


## Setup cluster resources with Dask-jobqueue


```python
from dask_jobqueue import SLURMCluster
```


```python
from dask.distributed import Client, progress
```


```python
import time
```


```python
cluster = SLURMCluster(memory="42GB", cores=8, processes=1, queue="general", walltime='01:00:00')
```


```python
print(cluster.job_script())
```

    #!/usr/bin/env bash
    
    #SBATCH -J dask-worker
    #SBATCH -p general
    #SBATCH -n 1
    #SBATCH --cpus-per-task=8
    #SBATCH --mem=40G
    #SBATCH -t 01:00:00
    
    /users/yourusername/.conda/envs/jupyterhub/bin/python3 -m distributed.cli.dask_worker tcp://129.24.243.21:40581 --name dummy-name --nthreads 8 --memory-limit 39.12GiB --nanny --death-timeout 60
    



```python
cluster.scale(4)
```

# A loop to check when all the resources are ready


```python
for x in range(10):
    print(cluster)
    time.sleep(5)
```

    SLURMCluster('tcp://172.16.2.42:46451', workers=0, threads=0, memory=0 B)
    SLURMCluster('tcp://172.16.2.42:46451', workers=1, threads=8, memory=42.00 GB)
    SLURMCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    SLURMCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    SLURMCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    SLURMCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    SLURMCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    SLURMCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    SLURMCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    SLURMCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)



```python
client = Client(cluster)
```

# Run a simple parallel program to test functionality


```python
def slow_increment(x): 
    time.sleep(1)
    return x + 1 

```


```python
futures = client.map(slow_increment, range(5000))
```


```python
progress(futures)
```


    VBox()


## Demonstrate how dask integrates with Scikit-Learn


```python
from joblib import parallel_backend
from sklearn.datasets import load_digits
from sklearn.model_selection import RandomizedSearchCV
from sklearn.svm import SVC
import numpy as np

digits = load_digits()

param_space = {
    'C': np.logspace(-6, 6, 13),
    'gamma': np.logspace(-8, 8, 17),
    'tol': np.logspace(-4, -1, 4),
    'class_weight': [None, 'balanced'],
}

model = SVC(kernel='rbf')
search = RandomizedSearchCV(model, param_space, cv=3, n_iter=50, verbose=10)

# Serialize the training data only once to each worker
with parallel_backend('dask', scatter=[digits.data, digits.target]):
    search.fit(digits.data, digits.target)

```

    Fitting 3 folds for each of 50 candidates, totalling 150 fits


    [Parallel(n_jobs=-1)]: Using backend DaskDistributedBackend with 32 concurrent workers.
    [Parallel(n_jobs=-1)]: Done   8 tasks      | elapsed:    2.2s
    [Parallel(n_jobs=-1)]: Done  21 tasks      | elapsed:    2.9s
    [Parallel(n_jobs=-1)]: Done  34 tasks      | elapsed:    3.5s
    [Parallel(n_jobs=-1)]: Done  49 tasks      | elapsed:    3.8s
    [Parallel(n_jobs=-1)]: Done  64 tasks      | elapsed:    4.1s
    [Parallel(n_jobs=-1)]: Done  81 tasks      | elapsed:    4.6s
    [Parallel(n_jobs=-1)]: Done 103 out of 150 | elapsed:    5.0s remaining:    2.3s
    [Parallel(n_jobs=-1)]: Done 119 out of 150 | elapsed:    5.3s remaining:    1.4s
    [Parallel(n_jobs=-1)]: Done 135 out of 150 | elapsed:    5.7s remaining:    0.6s
    [Parallel(n_jobs=-1)]: Done 150 out of 150 | elapsed:    6.1s finished



```python
print(search)
```

    RandomizedSearchCV(cv=3, estimator=SVC(),
                       param_distributions={'C': array([1.e-06, 1.e-05, 1.e-04, 1.e-03, 1.e-02, 1.e-01, 1.e+00, 1.e+01,
           1.e+02, 1.e+03, 1.e+04, 1.e+05, 1.e+06]),
                                            'class_weight': [None, 'balanced'],
                                            'gamma': array([1.e-08, 1.e-07, 1.e-06, 1.e-05, 1.e-04, 1.e-03, 1.e-02, 1.e-01,
           1.e+00, 1.e+01, 1.e+02, 1.e+03, 1.e+04, 1.e+05, 1.e+06, 1.e+07,
           1.e+08]),
                                            'tol': array([0.0001, 0.001 , 0.01  , 0.1   ])},
                       verbose=10)



```python

```
