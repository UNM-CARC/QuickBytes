## Example of parallelization with Jupyter hub using dask and scikit-learn




## Setup cluster resources with dask-jobqueue


```python
from dask_jobqueue import PBSCluster
```


```python
from dask.distributed import Client, progress
```


```python
import time
```


```python
cluster = PBSCluster(memory="42GB",cores=8, resource_spec="nodes=1:ppn=8", queue="default", walltime='01:00:00')
```


```python
print(cluster.job_script())
```

    #!/usr/bin/env bash
    
    #PBS -N dask-worker
    #PBS -q default
    #PBS -l nodes=1:ppn=8
    #PBS -l walltime=01:00:00
    JOB_ID=${PBS_JOBID%%.*}
    
    /opt/local/anaconda3/envs/jupyterhub/bin/python -m distributed.cli.dask_worker tcp://172.16.2.42:46451 --nthreads 8 --memory-limit 42.00GB --name name --nanny --death-timeout 60
    



```python
cluster.scale(4)
```

# A loop to check when all the resources are ready


```python
for x in range(10):
    print(cluster)
    time.sleep(5)
```

    PBSCluster('tcp://172.16.2.42:46451', workers=0, threads=0, memory=0 B)
    PBSCluster('tcp://172.16.2.42:46451', workers=1, threads=8, memory=42.00 GB)
    PBSCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    PBSCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    PBSCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    PBSCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    PBSCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    PBSCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    PBSCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)
    PBSCluster('tcp://172.16.2.42:46451', workers=4, threads=32, memory=168.00 GB)



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
# Scikit-learn bundles joblib, so you need to import from
# `sklearn.externals.joblib` instead of `joblib` directly
from sklearn.externals.joblib import parallel_backend
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
    /opt/local/anaconda3/envs/jupyterhub/lib/python3.6/site-packages/sklearn/model_selection/_search.py:842: DeprecationWarning: The default of the `iid` parameter will change from True to False in version 0.22 and will be removed in 0.24. This will change numeric results when test-set sizes are unequal.
      DeprecationWarning)



```python
print(search)
```

    RandomizedSearchCV(cv=3, error_score='raise-deprecating',
              estimator=SVC(C=1.0, cache_size=200, class_weight=None, coef0=0.0,
      decision_function_shape='ovr', degree=3, gamma='auto_deprecated',
      kernel='rbf', max_iter=-1, probability=False, random_state=None,
      shrinking=True, tol=0.001, verbose=False),
              fit_params=None, iid='warn', n_iter=50, n_jobs=None,
              param_distributions={'C': array([1.e-06, 1.e-05, 1.e-04, 1.e-03, 1.e-02, 1.e-01, 1.e+00, 1.e+01,
           1.e+02, 1.e+03, 1.e+04, 1.e+05, 1.e+06]), 'gamma': array([1.e-08, 1.e-07, 1.e-06, 1.e-05, 1.e-04, 1.e-03, 1.e-02, 1.e-01,
           1.e+00, 1.e+01, 1.e+02, 1.e+03, 1.e+04, 1.e+05, 1.e+06, 1.e+07,
           1.e+08]), 'tol': array([0.0001, 0.001 , 0.01  , 0.1   ]), 'class_weight': [None, 'balanced']},
              pre_dispatch='2*n_jobs', random_state=None, refit=True,
              return_train_score='warn', scoring=None, verbose=10)



```python

```
