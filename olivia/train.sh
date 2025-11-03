#!/bin/bash
#SBATCH --job-name=test-train
#SBATCH --account=nn12017k
#SBATCH --time=00:10:00
#SBATCH --output=outputs/train-%j.out
#SBATCH --error=outputs/train-%j.err
#SBATCH --partition=accel
#SBATCH --nodes=1                     # Single compute node
#SBATCH --ntasks-per-node=1          # One task (process) on the node
#SBATCH --cpus-per-task=72           # Reserve 72 CPU cores
#SBATCH --mem-per-gpu=110G           # Request 110 GB of CPU RAM per GPU
#SBATCH --gpus-per-node=1            # Request 1 GPU

CONTAINER="/cluster/work/support/container/pytorch_nvidia_25.06_arm64.sif"
BIND="/cluster/projects/nn12017k/"

CONFIG_NAME=template_configs/main-core.yaml
CONTAINER_SCRIPT=$(pwd -P)/run_pytorch.sh
echo $CONTAINER_SCRIPT
VENV=$(pwd -P)/.venv
export VIRTUAL_ENV=$VENV

# Clone and pip install anemoi repos from the container
apptainer exec -B $BIND $CONTAINER $CONTAINER_SCRIPT
