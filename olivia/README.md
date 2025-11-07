# Example of using anemoi with a NGC pytorch container

## Fetch the container on the login node
```bash
apptainer pull --arch arm64 pytorch_25.08-py3.sif docker://nvcr.io/nvidia/pytorch:25.08-py3
```

We do this on the login node. Remember to use the `--arch arm64` setting, since we pull it on a
node with x86 architecture and want to use it on a node with arm64 CPUs.

## Installation

Add the packages missing in the NGC container to `requirements_additions.txt`.
This can be tricky since if you add packages that are already in the
NGC python environment it won't work. So it can be a good idea to
check what's already in the container first:

```bash
apptainer exec pytorch_25.08-py3.sif pip freeze
```

This shows all installed packages. Avoid adding these to `requirements_additions.txt` to prevent conflicts.

### Why use squashfs?

**We are not allowed to use venv directly on Olivia since it breaks the filesystem.**
Creating a Python virtual environment with anemoi creates 50,000+ small files, which causes
problems for the shared filesystem.

Squashfs is a workaround - it packages the entire venv into a single compressed file:

- **One file**: `anemoi-env.sqsh` instead of 50,000+ files
- **Filesystem friendly**: No strain on shared storage
- **Fast**: Better I/O performance
- **Portable**: Easy to copy/backup

### Create the squashfs environment

```bash
sbatch create_squashfs.sh
```

This will:
1. Start a compute job with arm64 architecture.
2. Create a virtual environment inside the container
3. Install anemoi packages from `requirements_additions.txt`
4. Test the installation
5. Create `anemoi-env.sqsh` (~107 MB)
6. Clean up temporary files

Takes about 15-20 minutes.

### Manual installation (if you want to customize)

```bash
# Start interactive job
srun --account=nn9997k --partition=accel --nodes=1 --time=01:00:00 --pty bash

# Create venv and install packages
apptainer exec -B $PWD pytorch_25.08-py3.sif python3 -m venv anemoi-venv --system-site-packages
apptainer exec -B $PWD pytorch_25.08-py3.sif bash -c "source anemoi-venv/bin/activate && pip install -r requirements_additions.txt"

# Test
apptainer exec -B $PWD pytorch_25.08-py3.sif bash -c "source anemoi-venv/bin/activate && python3 test_imports.py"

# Create squashfs and cleanup
mksquashfs anemoi-venv anemoi-env.sqsh -noappend
rm -rf anemoi-venv
```

## Testing

### Test the installation
```bash
sbatch run_test.sh
```

Runs a simple import test to verify all anemoi packages work.

### Test single GPU training
```bash
sbatch run_train_1gpu.sh
```

### Test 4 GPU DDP training
```bash
sbatch run_train_4gpu.sh
```

These run simple PyTorch training tests to verify multi-GPU functionality with NCCL.
These tests do not test anemoi but test if the GPUs are working as expected.

## Using the squashfs environment

The squashfs file is mounted as `/user-software` inside the container:

```bash
apptainer exec --nv \
    -B $PWD \
    -B anemoi-env.sqsh:/user-software:image-src=/ \
    pytorch_25.08-py3.sif \
    python3 your_script.py
```

What each flag does:
- `--nv` - Enable GPU access (REQUIRED for NCCL and multi-GPU)
- `-B $PWD` - Mount current directory
- `-B anemoi-env.sqsh:/user-software:image-src=/` - Mount squashfs as `/user-software`

Python automatically finds packages in `/user-software/lib/python3.12/site-packages`.

### Multi-GPU training with torchrun

```bash
apptainer exec --nv -B $PWD -B anemoi-env.sqsh:/user-software:image-src=/ \
    pytorch_25.08-py3.sif \
    torchrun --standalone --nproc_per_node=4 train_script.py
```

## Important: Always use `--nv` for GPU operations

```bash
# ✓ Correct - GPU access enabled
apptainer exec --nv pytorch_25.08-py3.sif python3 script.py

# ✗ Wrong - NCCL will fail with "Failed to open libnvidia-ml.so.1"
apptainer exec pytorch_25.08-py3.sif python3 script.py
```

The `--nv` flag binds NVIDIA driver libraries into the container, which are required for
multi-GPU communication (NCCL), GPU monitoring, and proper CUDA initialization.

## Test results

Performance from 4x GH200 GPUs:

| Configuration | Time (15 epochs) | Speedup |
|--------------|------------------|---------|
| 1 GPU        | 1.51 seconds     | 1.0x    |
| 4 GPUs (DDP) | 0.58 seconds     | 2.6x    |

(Small model, synthetic data - real workloads will show different scaling)

## Package versions

See `requirements_additions.txt`:
- anemoi-utils: 0.4.38
- anemoi-datasets: 0.7.7
- anemoi-models: 0.9.7
- anemoi-graphs: 0.7.1
- anemoi-training: 0.6.7

## Troubleshooting

**NCCL errors about libnvidia-ml.so.1**
Solution: Add `--nv` flag to `apptainer exec`

**Python can't find anemoi packages**
Check: Squashfs is mounted correctly with `-B anemoi-env.sqsh:/user-software:image-src=/`

**Can't write to `/user-software`**
This is expected - squashfs is read-only. Install packages before creating the squashfs.

## Links

- [Anemoi Homepage](https://anemoi.ecmwf.int/)
- [Anemoi Training Docs](https://anemoi-training.readthedocs.io/)
- [Anemoi GitHub](https://github.com/ecmwf/anemoi-core)
