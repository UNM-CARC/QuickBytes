# Introduction to TensorFlow

The relatively recent mainstream availability of complex algorithms and computationally efficient hardware is creating a platform for new innovations never before available to the scientific computing world. Since the development of computer systems, computing times have been drastically reduced, making more complex computations feasible. The continuous cycle of improvements in computation speeds and hardware leading to ever more complex computations can be seen in the scaling of hardware to meet these more complex computation goals. A resolution to this cycle can be found in the utilization of GPUs in high-performance computing for machine learning and deep learning algorithms.

Most of the complex computing strategies can be simplified into basic linear algebra operations such as addition, multiplication, subtraction, and inversion. Out of the listed operations, matrix multiplication and inversion are the most computationally expensive operations.

Most matrix operations are performed sequentially on the CPU resulting in computation time that scales with the size of the matrix as a factor &theta;(n<sup>3</sup>). Hence, computation cycles and duration of time to be allocated towards computation is proportional to the size of matrices under the constrained hardware with limited cache memory and RAM. The same problem still exists with multicore systems or distributed systems due to the threshold on the resources mentioned. On the other hand, a GPU is composed of several thousand cores, combining to provide the user with several GBs of computational memory compared to the MBs provided by CPU cache memory. The distributed computing this configuration provides enables parallelism across GPU cores and allows a super fast flow of data resulting from incredibly high bandwidth. This distribution across multiple cores amounts to massively reduced computation time as the device is able to scale its performance with data size.

The enormous gains in computation time should give researchers a valid reason to switch from CPUs to GPUs for computationally heavy operations where the CPU-based operations do not scale with the data at a constant rate. Utilization of this methodology will provide enormous benefits for the computationally heavy domains such as machine learning, deep learning, linear algebra, optimization, data structures, etc. For real CPU-vs-GPU benchmark numbers on current CARC hardware, see the [Tensorflow with multiple GPUs](https://github.com/UNM-CARC/QuickBytes/blob/master/multiGPU_tensorflow_tutorial.md) QuickByte.

TensorFlow is an open source deep learning library provided by Google. It provides primitives for function definitions on tensors and a mechanism to compute their derivatives automatically. It uses a tensor to represent any multidimensional array of numbers.

**Comparison between NumPy and TensorFlow**

TensorFlow's computational housing is a tensor, similar to NumPy's housing of data in ndarrays, making both of them N-d array libraries.

However, NumPy does not offer a method to create tensor functions and automatically compute derivatives, nor does it support GPU implementation. Thus, for processing data of higher dimensions, TensorFlow outperforms NumPy arrays due largely to its GPU implementations.

**NumPy vs TensorFlow Implementations**

***NumPy Implementation of Matrix Addition***

```python
import numpy as np
a=np.zeros((2,2))
b=np.zeros((2,2))
np.sum(b,axis=0)
a.shape
np.reshape(b,(1,4))
```

***TensorFlow Implementation of Matrix Addition***

```python
import tensorflow as tf
a=tf.zeros((2,2))
b=tf.ones((2,2))
tf.reduce_sum(b,axis=1)
a.shape
tf.reshape(b,(1,4))
```

TensorFlow 2.x runs in eager execution mode by default, meaning operations run and return values immediately, just like NumPy. Older TensorFlow 1.x code required wrapping everything in a `tf.Session()` and explicitly calling `.eval()` or `sess.run()` to get a value out of a computational graph. That pattern was removed in TensorFlow 2.x, so this QuickByte has been updated to reflect current usage.

NumPy for example:

```python
a=np.zeros((2,2))
print(a)
```

will immediately give the value of "a":

```
[[0. 0.]
 [0. 0.]]
```

And in modern TensorFlow, the same is true:

```python
a=tf.zeros((2,2))
print(a)
```

```
tf.Tensor(
[[0. 0.]
 [0. 0.]], shape=(2, 2), dtype=float32)
```

No session or `.eval()` call is needed to see the value.

**TensorFlow Variables**

Similar to other programming language variables, TensorFlow uses a variable object to store and update parameters. They are stored in memory buffers that contain tensors. In TensorFlow 2.x, variables are initialized as soon as they're created, so no separate initialization step is needed:

```python
W=tf.Variable(tf.zeros((2,2)), name="weights")
R=tf.Variable(tf.random.normal((2,2)), name="random_weights")
print(W)
print(R)
```

```
<tf.Variable 'weights:0' shape=(2, 2) dtype=float32, numpy=
array([[0., 0.],
       [0., 0.]], dtype=float32)>
<tf.Variable 'random_weights:0' shape=(2, 2) dtype=float32, numpy=
array([[ 0.36164567, -1.2414476 ],
       [-0.09992382, -2.0074232 ]], dtype=float32)>
```

Converting NumPy data to a tensor:

```python
a=np.zeros((3,3))
t_a=tf.convert_to_tensor(a)
print(t_a)
```

```
tf.Tensor(
[[0. 0. 0.]
 [0. 0. 0.]
 [0. 0. 0.]], shape=(3, 3), dtype=float64)
```

A TensorFlow session for performing multiplication looked like this in TensorFlow 1.x:

```python
a=tf.constant(9999999)
b=tf.constant(111111111)
c=a*b
with tf.Session() as sess:
     print(sess.run(c))
```

In TensorFlow 2.x, this is much simpler since operations execute immediately, no session needed. Note the explicit `int64` dtype below, since the product of these two numbers overflows the default 32-bit integer type:

```python
a=tf.constant(9999999, dtype=tf.int64)
b=tf.constant(111111111, dtype=tf.int64)
c=a*b
print(c)
```

```
tf.Tensor(1111110998888889, shape=(), dtype=int64)
```

Older TensorFlow code also used `tf.placeholder` to define entry points for data that would be filled in later via a `feed_dict`, since a computational graph had to be fully built before any data was fed into it. In TensorFlow 2.x you can just write a regular Python function and call it directly with your data. Optionally decorating it with `@tf.function` compiles it into a callable TensorFlow graph for better performance:

```python
@tf.function
def multiply(input1, input2):
    return tf.multiply(input1, input2)

print(multiply(tf.constant([7.]), tf.constant([2.])))
```

```
tf.Tensor([14.], shape=(1,), dtype=float32)
```

*This quickbyte was validated on 7/30/2026*
