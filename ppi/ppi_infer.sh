#!/bin/bash
#$ -N inference
#$ -b n
#$ -S /bin/bash
#$ -l h_data=10G
#$ -l h_rss=10G
#$ -l h_rt=01:00:00
#$ -q gpu-r8.q
#$ -l h=gpu-03.ppi.met.no
#$ -o /lustre/storeB/project/fou/hi/foccus/mateuszm/run-anemoi-ocean/ppi/output/
#$ -e /lustre/storeB/project/fou/hi/foccus/mateuszm/run-anemoi-ocean/ppi/output/

RUN_DIR=/lustre/storeB/project/fou/hi/foccus/mateuszm/run-anemoi-ocean/ppi/
CONFIG_NAME=$RUN_DIR/template_configs/main-anemoi-infer.yaml
#CONFIG_NAME=$(pwd -P)/main_infer.yaml

#Should not have to change these
CONTAINER_SCRIPT=$RUN_DIR/run_pytorch_infer.sh

CONTAINER=/lustre/storeB/project/fou/hi/foccus/container/ocean-ai-pytorch-2.3.1-rocm-6.0.3-py-3.11.5-v0.0.sif

VENV=$RUN_DIR/.venv
export VIRTUAL_ENV=$VENV

module use /modules/MET/rhel8/user-modules
module load singularity/3.11.5

singularity exec --nv -B /lustre/:/lustre/ $CONTAINER $CONTAINER_SCRIPT $CONFIG_NAME
