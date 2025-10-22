#!/bin/bash
#SBATCH --job-name="InferH200"
#SBATCH --output=output/Infer_%j.log
#SBATCH --gres=gpu:nvidia_h200_nvl:2
#SBATCH --partition=gpuB-prod
#SBATCH --time=24:00:00
#SBATCH --account=hi-training
#SBATCH --mem=80G
#SBATCH --ntasks-per-node=1


#source  /modules/rhel9/x86_64/mamba-mf3/etc/profile.d/ppimam.sh
#mamba activate /modules/rhel9/x86_64/mamba-mf3/envs/2025-08-development

#VENV=$(pwd -P)/.venv
#export VIRTUAL_ENV=$VENV


source $(pwd -P)/inf_env/bin/activate

CONFIG_DIR=$(pwd -P)/
CONFIG_NAME=main-anemoi-infer.yaml



export HYDRA_FULL_ERROR=1
export AIFS_BASE_SEED=1337420
#export PYTHONUSERBASE=$VIRTUAL_ENV
#export PATH=$PATH:$VIRTUAL_ENV/bin
ulimit -v unlimited
anemoi-inference run $CONFIG_NAME

