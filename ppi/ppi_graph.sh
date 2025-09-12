#!/bin/bash
#SBATCH --job-name="GraphGH200"
#SBATCH --output=output/GRAPH_%j.log
#SBATCH --gres=gpu:nvidia_gh200_480gb:1 
#SBATCH --partition=gpuB-arm-research
#SBATCH --time=01:00:00
#SBATCH --account=hi-training
#SBATCH --mem=50g
##SBATCH --mail-type=ALL
##SBATCH --mail-user=mateuszm@met.no


GRAPH_NAME=thinning_4_trim_edge_10_res_10.pt

source /modules/rhel9/aarch64/mamba-mf3/etc/profile.d/ppimam.sh
mamba activate /home/mateuszm/.conda/envs/gh200-p3.11.5 

VENV=$(pwd -P)/.venv
export VIRTUAL_ENV=$VENV

RUN_DIR=/lustre/storeB/project/fou/hi/foccus/ppi-experiments/initial_setup/run-anemoi-ocean/ppi/
CONFIG_DIR=$(pwd -P)/
CONFIG_NAME=$(pwd -P)/template_configs/graph.yaml

export HYDRA_FULL_ERROR=1
export AIFS_BASE_SEED=1337420
export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin

anemoi-graphs create $CONFIG_NAME $GRAPH_NAME
