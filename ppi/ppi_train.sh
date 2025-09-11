#!/bin/bash
#SBATCH --job-name="TrainGH200"
#SBATCH --output=output/TRAIN_%j.log
#SBATCH --gres=gpu:nvidia_gh200_480gb:1 
#SBATCH --partition=gpuB-arm-research
#SBATCH --time=01:00:00
#SBATCH --account=hi-training
#SBATCH --mem=200g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mateuszm@met.no


source /modules/rhel9/aarch64/mamba-mf3/etc/profile.d/ppimam.sh
mamba activate /home/mateuszm/.conda/envs/gh200-p3.11.5 

VENV=$(pwd -P)/.venv
export VIRTUAL_ENV=$VENV

RUN_DIR=/lustre/storeB/project/fou/hi/foccus/ppi-experiments/initial_setup/run-anemoi-ocean/ppi/
CONFIG_DIR=$(pwd -P)/
CONFIG_NAME=main-core.yaml

export HYDRA_FULL_ERROR=1
export AIFS_BASE_SEED=1337420

srun run_pytorch.sh $CONFIG_DIR $CONFIG_NAME

