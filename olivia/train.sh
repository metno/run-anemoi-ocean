#!/bin/bash
#SBATCH --account=nn12017k
#SBATCH --job-name=train
#SBATCH --partition=accel
#SBATCH --nodes=1
#SBATCH --gpus=1
#SBATCH --cpus-per-task=72
#SBATCH --mem-per-cpu=2G
#SBATCH --time=7-00:00:00
#SBATCH --output=outputs/train_4_%j.out

echo "Multi-GPU Training Test (DDP with NCCL)"
echo ""

SIF=/cluster/projects/nn12017k/container/pytorch_25.08-py3.sif
SQSH=$PWD/anemoi-env.sqsh
export APPTAINERENV_PREPEND_PATH=/user-software/bin
CONFIG_NAME=SF_main.yaml
echo $CONFIG_NAME

apptainer exec --nv -B /cluster/work/projects/nn12017k/ -B /cluster/projects/nn12017k/ -B $PWD -B ${SQSH}:/user-software:image-src=/ ${SIF} \
    bash -c "source /user-software/bin/activate && python -m anemoi.training train --config-dir=$PWD --config-name=$CONFIG_NAME"

#apptainer exec --nv -B $PWD -B ${SQSH}:/user-software:image-src=/ ${SIF} \
#    bash -c "source /user-software/bin/activate && python train_single_gpu.py"
# bash -c "source /user-software/bin/activate && torchrun --standalone --nproc_per_node=4 train_multi_gpu.py"
