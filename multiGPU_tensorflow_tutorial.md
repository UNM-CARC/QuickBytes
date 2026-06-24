# Using TensorFlow on Multiple GPUs

TensorFlow is a popular open source platform for machine learning that enables parallelism across GPU cores. This parallelism results in considerably reduced computation times, as performance scales with data size in a way that CPU-based operations cannot match.

## Setting Up Your Environment

Before getting started, you will need to create a Miniconda environment with TensorFlow and its dependencies.

### Create the Conda Environment

From the Easley login node, load the Miniconda module and create a new environment:

```bash
module load miniconda3
conda create --name tf_env python=3.13
conda activate tf_env
```

### Install TensorFlow and Dependencies

```bash
pip install "tensorflow[and-cuda]"
pip install nvidia-cudnn-cu12
pip install numpy matplotlib scikit-learn ipykernel
```

### Configure GPU Libraries

TensorFlow requires the NVIDIA GPU libraries to be on your library path. Run the following commands to configure this automatically whenever you activate your environment:

```bash
mkdir -p $CONDA_PREFIX/etc/conda/activate.d
cat > $CONDA_PREFIX/etc/conda/activate.d/tf_gpu_libs.sh << 'EOF'
NVIDIA_LIB_DIR=$(python -c "import site; print(site.getsitepackages()[0])")/nvidia
export LD_LIBRARY_PATH=$(find $NVIDIA_LIB_DIR -type d -name lib | tr '\n' ':')$LD_LIBRARY_PATH
EOF
```

### Register the Environment as a Jupyter Kernel

To use this environment in JupyterHub, register it as a kernel:

```bash
python -m ipykernel install --user --name tf_env --display-name "Python (tf_env)"
```

### Verify GPU Access

To confirm TensorFlow can see the GPUs, request an interactive session on a GPU node and run the following:

```bash
srun -G 2 -p l40s --pty bash
conda activate tf_env
python -c "import tensorflow as tf; print(tf.__version__); print(tf.config.list_physical_devices('GPU'))"
```

You should see output similar to:
2.21.0

[PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU'), PhysicalDevice(name='/physical_device:GPU:1', device_type='GPU')]

## Multi-GPU Training with TensorFlow

This tutorial covers single-host, multi-GPU synchronous training using the `MirroredStrategy` API in Keras. The example below trains a neural network on a synthetic dataset, distributing the work across all available GPUs. Save the full script as `tf_multiGPU_test.py` and run it from an interactive GPU session (as shown in the "Verify GPU Access" step above), or submit it as a Slurm batch job.

```python
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from sklearn.datasets import make_multilabel_classification
from sklearn.model_selection import train_test_split

Nin = 10
Nout = 3

learning_rate = 1e-3
epochs = 10
batch_size = 32
neurons_per_hidden_layer = 32

xin, yin = make_multilabel_classification(
    n_samples=100000,
    n_features=Nin,
    n_classes=Nout,
    n_labels=2
)

def create_model(n_neurons):
    model = models.Sequential([
        layers.Input(shape=(Nin,)),
        layers.Dense(n_neurons, kernel_initializer='he_uniform', activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(n_neurons, kernel_initializer='he_uniform', activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(Nout, activation='sigmoid')
    ])
    return model

def get_dataset():
    x_train, x_test, y_train, y_test = train_test_split(xin, yin)

    num_val_samples = 10 * y_train.shape[0] // 100

    x_val = x_train[-num_val_samples:]
    x_train = x_train[:-num_val_samples]
    y_val = y_train[-num_val_samples:]
    y_train = y_train[:-num_val_samples]

    return (
        tf.data.Dataset.from_tensor_slices((x_train, y_train)).batch(batch_size, drop_remainder=True),
        tf.data.Dataset.from_tensor_slices((x_val, y_val)).batch(batch_size, drop_remainder=True),
        tf.data.Dataset.from_tensor_slices((x_test, y_test)).batch(batch_size, drop_remainder=True),
        y_test
    )

strategy = tf.distribute.MirroredStrategy()
print(f'Number of devices: {strategy.num_replicas_in_sync}')

opt = keras.optimizers.Adam(learning_rate=learning_rate)

with strategy.scope():
    model = create_model(neurons_per_hidden_layer)
    model.compile(
        optimizer=opt,
        loss='binary_crossentropy',
        metrics=['binary_accuracy']
    )

train_dataset, val_dataset, test_dataset, ytest = get_dataset()

history = model.fit(
    train_dataset,
    epochs=epochs,
    validation_data=val_dataset,
    verbose=1
)

plt.figure()
plt.title('Loss')
plt.plot(history.history['loss'], label='train')
plt.plot(history.history['val_loss'], label='validation')
plt.legend()
plt.savefig('training_loss.png')
print('Saved training loss plot to training_loss.png')

score = model.evaluate(test_dataset)
print(f'Test accuracy: {score[1]:.4f}')

ypred = model.predict(test_dataset)

randind = np.random.randint(ytest.shape[0])

plt.figure()
plt.title('Predictions vs Ground Truth')
plt.plot(ytest[randind], 'o', label='ground truth')
plt.plot(ypred[randind], '.', label='predicted')
plt.ylim([-0.05, 1.05])
plt.legend()
plt.savefig('predictions_vs_groundtruth.png')
print('Saved predictions plot to predictions_vs_groundtruth.png')
print('Test complete.')
```

The core idea this script demonstrates is **data parallelism**. Rather than splitting the neural network itself across GPUs, TensorFlow keeps an identical copy of the full model on each GPU and splits each training batch between them. Every GPU computes gradients on its own slice of the data; those gradients are averaged across devices, and the resulting update is applied to all copies of the model in sync — so the model trains as if it saw the whole batch, just faster. This is what `tf.distribute.MirroredStrategy` does for you automatically: by default, it detects every available GPU on the node. It mirrors the model across them, and the only thing you have to do differently from a single-GPU training script is create and compile the model inside `strategy.scope()` so TensorFlow knows to set up that mirroring. Everything else — the dataset, the training loop, the `fit()` call — looks like ordinary single-GPU Keras code. This kind of synchronous multi-GPU training is most worth using when your model or batch size is large enough that a single GPU is a bottleneck; for a small toy network like this one, the speedup mostly demonstrates the mechanism rather than reflecting a realistic workload. To confirm the parallelism is actually happening, open a separate terminal, SSH into the compute node, and run `nvidia-smi` during training — you should see roughly even GPU utilization split across the devices you requested. The rest of the script is standard supporting plumbing: it generates a synthetic dataset since the focus is the multi-GPU mechanics rather than the data itself, saves plots to disk instead of calling `plt.show()` (compute nodes have no display, so `Agg` is used as a non-interactive backend), and finishes by printing test accuracy and a sample prediction plot as a sanity check that training actually worked.

*This quickbyte was validated on 6/24/2026.*
