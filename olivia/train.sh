#!/bin/bash
#SBATCH --account=nn12017k
#SBATCH --job-name=train_4gpu
#SBATCH --partition=accel
#SBATCH --nodes=1
#SBATCH --gpus=4
#SBATCH --cpus-per-task=72
#SBATCH --mem=0
#SBATCH --time=00:10:00
#SBATCH --output=outputs/train_4gpu_%j.out

echo "Multi-GPU Training Test (DDP with NCCL)"
echo ""

SIF=/cluster/projects/nn12017k/container/pytorch_25.08-py3.sif
SQSH=./anemoi-env.sqsh
export APPTAINERENV_PREPEND_PATH=/user-software/bin
CONFIG_NAME=$PWD/main-core.yaml

apptainer exec --nv -B $PWD -B ${SQSH}:/user-software:image-src=/ ${SIF} \
    bash -c "source /user-software/bin/activate && anemoi-training train --config-name=$CONFIG_NAME"

# bash -c "source /user-software/bin/activate && torchrun --standalone --nproc_per_node=4 train_multi_gpu.py"
