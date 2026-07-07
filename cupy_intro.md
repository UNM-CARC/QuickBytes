# CuPy — CUDA in Python

[CuPy](https://cupy.dev/) is a GPU array library that implements almost the entire NumPy (and a good chunk of SciPy) API. If you already know NumPy, you already know most of CuPy — the difference is that `cupy.ndarray` lives in GPU memory and its operations run as CUDA kernels instead of on the CPU. For array-heavy numerical code, this can mean large speedups with very little code change.

This QuickByte covers installing CuPy on Easley, basic usage, and a real CPU-vs-GPU benchmark. It closes with a pointer to a more advanced multi-GPU example (using NCCL) from the CS491/591 HPC course lecture on GPU computation.

## Installing CuPy

Create a Conda environment and install CuPy:

```bash
module load miniconda3
conda create -n cupy_env python=3.11 -y
conda activate cupy_env
```

> **First time using `conda activate` on Easley?** See the note in the [Miniconda QuickByte](anaconda_intro.md) about needing to `source ~/.bashrc` if you get `CondaError: Run 'conda init' before 'conda activate'`.

Two things to watch for, both found by actually installing this on Easley:

**Don't `conda install -c conda-forge cupy` directly.** As of this writing that pulls in a build linked against CUDA 13.x, which needs an NVIDIA driver version Easley's GPU nodes don't have yet (`cudaErrorInsufficientDriver`). Use the CUDA-12 pip wheel instead, which matches Easley's driver:

```bash
pip install "cupy-cuda12x[ctk]"
```

The `[ctk]` extra matters too — without it, CuPy can import and do simple operations, but anything that needs to JIT-compile a CUDA kernel at runtime (e.g. `cupy.random`) fails with `RuntimeError: Failed to find CUDA headers`. The `[ctk]` extra bundles the CUDA toolkit headers CuPy needs to compile kernels on the fly, so you don't need a separate `module load cuda` or a matching system CUDA install.

## Basic Usage

Request a GPU and start Python:

```bash
srun --partition l40s --mem 16G --ntasks 1 --cpus-per-task 4 -G 1 --pty bash
```

```bash
module load miniconda3
conda activate cupy_env
python3
```

```python
>>> import numpy as np
>>> import cupy as cp
>>>
>>> a_cpu = np.array([1, 2, 3])
>>> a_gpu = cp.array([1, 2, 3])
>>> print(a_gpu)
[1 2 3]
>>> print(type(a_gpu))
<class 'cupy.ndarray'>
>>> print(a_gpu.sum())
6
```

`a_gpu` is a real GPU array — `a_gpu.sum()` runs as a CUDA kernel. To bring a result back into a normal NumPy array on the CPU, use `cupy.asnumpy`:

```python
>>> print(cp.asnumpy(a_gpu))
[1 2 3]
```

Most NumPy code ports over by just swapping the `import numpy as np` for `import cupy as cp` and calling `cp.asnumpy()` on anything you need back on the CPU (e.g. before plotting with Matplotlib, which doesn't understand GPU arrays).

## CPU vs. GPU Benchmark

The following script times matrix multiplication on CPU (NumPy) versus GPU (CuPy) at increasing sizes. `cp.cuda.Stream.null.synchronize()` is important here — CUDA operations are asynchronous by default, so without it the GPU timer would stop before the GPU actually finished the work.

```bash
cat > cupy_benchmark.py <<'EOF'
import time
import numpy as np
import cupy as cp

SIZES = [1000, 2000, 4000, 8000]

def bench_matmul_cpu(n):
    a = np.random.rand(n, n)
    b = np.random.rand(n, n)
    start = time.perf_counter()
    a @ b
    return time.perf_counter() - start

def bench_matmul_gpu(n):
    a = cp.random.rand(n, n)
    b = cp.random.rand(n, n)
    cp.cuda.Stream.null.synchronize()
    start = time.perf_counter()
    a @ b
    cp.cuda.Stream.null.synchronize()
    return time.perf_counter() - start

for n in SIZES:
    cpu_t = bench_matmul_cpu(n)
    gpu_t = bench_matmul_gpu(n)
    print(f"N={n}  CPU: {cpu_t:.4f}s  GPU: {gpu_t:.4f}s  speedup: {cpu_t / gpu_t:.1f}x")
EOF
```

```bash
python cupy_benchmark.py
```

Real output from a single L40S GPU on Easley:

```text
N=1000  CPU: 0.0212s  GPU: 0.0409s  speedup: 0.5x
N=2000  CPU: 0.0613s  GPU: 0.0141s  speedup: 4.3x
N=4000  CPU: 0.4516s  GPU: 0.1042s  speedup: 4.3x
N=8000  CPU: 3.5050s  GPU: 0.8314s  speedup: 4.2x
```

Notice N=1000 is actually *slower* on the GPU (0.5x). This is a real and important pattern, not a bug: every GPU operation pays a fixed overhead (kernel launch, memory allocation) regardless of problem size. For small arrays, that overhead outweighs the GPU's raw compute advantage. The crossover point depends on the operation and hardware, but the lesson generalizes — moving small workloads to the GPU can make them *slower*, not faster.

## Going Further: Multi-GPU CuPy with NCCL and MPI

Once GPU code works on one GPU, a natural next step is to spread work across multiple GPUs using [NCCL](https://developer.nvidia.com/nccl) (NVIDIA Collective Communication Library) alongside `mpi4py`. NCCL deliberately mirrors MPI's API and terminology — `ncclAllReduce` corresponds to `MPI_Allreduce`, `ncclBroadcast` to `MPI_Bcast`, and so on — so if you already know MPI, the concepts transfer directly. The key difference is that NCCL operates directly on GPU memory (VRAM), bypassing the CPU entirely for speed.

The pattern for converting a CPU/MPI loop to GPU/CuPy is usually mechanical. For example, the core of an MPI-based π estimation loop:

```python
for i in range(rank, num_steps, num_procs):
    x = (i + 0.5) * step
    sum = sum + 4.0 / (1.0 + x * x)
    mypi = step * sum
```

becomes vectorized CuPy code that runs entirely on the GPU:

```python
x = cp.arange(rank, N, size, dtype=cp.float64)
x = (x + 0.5) * step_size
partial_sum = (4.0 / (1.0 + x * x)).sum()
```

**A real gotcha worth knowing about before you try this:** for cheap-per-element workloads like this one, allocating one huge array of size N per GPU runs out of GPU memory almost immediately for large N (`cupy.cuda.memory.OutOfMemoryError`), and even when it fits, the computation is so fast that multiple GPUs don't help — the fixed cost of setting up NCCL communication dominates. The fix is to process the work in fixed-size batches (accumulating a running sum instead of materializing the whole array at once), which keeps GPU memory use constant regardless of N and means more total work (larger N) directly translates into more compute — only then does adding a second GPU start paying off, and only for large enough problem sizes (roughly N ≥ 10¹⁰–10¹¹ in this example).

This multi-GPU/NCCL section is conceptual — the code patterns above are real, taken from the [CS491/591 HPC course Lecture 20: GPU Computation](https://fricke.co.uk/Teaching/CS491_591_HPC_2025_Fall/Lectures/Lecture_20-GPU_Computation.pdf), but a complete working multi-GPU NCCL script hasn't been tested against Easley for this QuickByte. If you want to build one, start from a batched single-GPU CuPy loop (proven to scale via `cupy`'s memory pool), add `mpi4py` for process launching, and initialize one `cupy.cuda.nccl.NcclCommunicator` per rank for the reduction step.

## Further Reading

- Official CuPy documentation: [docs.cupy.dev](https://docs.cupy.dev/en/stable/)
- CuPy vs. NumPy API compatibility: [docs.cupy.dev/en/stable/reference/comparison.html](https://docs.cupy.dev/en/stable/reference/comparison.html)
- NCCL documentation: [docs.nvidia.com/deeplearning/nccl](https://docs.nvidia.com/deeplearning/nccl/user-guide/docs/index.html)

*This quickbyte was validated on Easley on 7/7/2026.*
