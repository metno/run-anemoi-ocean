#!/bin/bash
#SBATCH --job-name=make-env
#SBATCH --account=nn12017k
#SBATCH --time=00:10:00
#SBATCH --output=outputs/make-env-%j.out
#SBATCH --error=outputs/make-env-%j.err
#SBATCH --partition=accel
#SBATCH --nodes=1                     # Single compute node
#SBATCH --ntasks-per-node=1          # One task (process) on the node
#SBATCH --cpus-per-task=72           # Reserve 72 CPU cores
#SBATCH --mem-per-gpu=110G           # Request 110 GB of CPU RAM per GPU
#SBATCH --gpus-per-node=1            # Request 1 GPU


cd $(pwd -P)

# Make files executable in the container (might not be needed)
chmod 770 env_setup.sh

CONTAINER="/cluster/work/support/container/pytorch_nvidia_25.06_arm64.sif"
BIND="/cluster/projects/nn12017k/"
# Clone and pip install anemoi repos from the container
apptainer exec -B $BIND $CONTAINER $(pwd -P)/env_setup.sh
