#!/bin/bash
#SBATCH --job-name="GraphH200"
#SBATCH --output=output/GRAPH_%j.log
#SBATCH --gres=gpu:nvidia_h200_nvl:2
#SBATCH --partition=gpuB-prod
#SBATCH --time=02:00:00
#SBATCH --account=hi-training
#SBATCH --mem=200g
#SBATCH --ntasks-per-node=1

GRAPH_NAME=trim_edge_10_res_12_MaskedPlanarAreaWeights.pt

source  /modules/rhel9/x86_64/mamba-mf3/etc/profile.d/ppimam.sh
mamba activate /home/mateuszm/.conda/envs/h200-p3.11.5

VENV=$(pwd -P)/.venv
export VIRTUAL_ENV=$VENV

RUN_DIR=/lustre/storeB/project/fou/hi/foccus/ppi-experiments/initial_setup/run-anemoi-ocean/ppi/
CONFIG_DIR=$(pwd -P)/
CONFIG_NAME=$(pwd -P)/template_configs/graph.yaml

export HYDRA_FULL_ERROR=1
export AIFS_BASE_SEED=1337420
export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin
ulimit -v unlimited
anemoi-graphs create $CONFIG_NAME $GRAPH_NAME
