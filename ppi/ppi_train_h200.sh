#!/bin/bash
#SBATCH --job-name="TrainH200"
#SBATCH --output=output/TRAIN_%j.log
#SBATCH --gres=gpu:nvidia_h200_nvl:1
#SBATCH --partition=gpuB-prod
#SBATCH --time=24:00:00
#SBATCH --account=havbris
#SBATCH --mem=16G
#SBATCH --ntasks-per-node=1


source  /modules/rhel9/x86_64/mamba-mf3/etc/profile.d/ppimam.sh
mamba activate /modules/rhel9/x86_64/mamba-mf3/envs/2025-08-development

VENV=$(pwd -P)/.venv
export VIRTUAL_ENV=$VENV

RUN_DIR=/lustre/storeB/project/fou/hi/foccus/ppi-experiments/initial_setup/run-anemoi-ocean/ppi/
CONFIG_DIR=$(pwd -P)/
CONFIG_NAME=main-core.yaml

export HYDRA_FULL_ERROR=1
export AIFS_BASE_SEED=1337420
export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin
ulimit -v unlimited
anemoi-training train --config-dir=$CONFIG_DIR --config-name=$CONFIG_NAME

