#!/bin/bash
#SBATCH --job-name="inf GH200"
#SBATCH --output=/lustre/storeB/project/fou/hi/foccus/mateuszm/run-anemoi-ocean/ppi/output/gpuHPLmpi-%x.%J.%N.out.log
#SBATCH --gres=gpu:nvidia_gh200_480gb:1 
#SBATCH --partition=gpuB-arm-research
#SBATCH --time=01:00:00
#SBATCH --account=hi-training
#SBATCH --mem=200g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mateuszm@met.no
#SBATCH --ntasks-per-node=2

#source  /modules/rhel9/aarch64/mamba-mf3/etc/profile.d/ppimam.sh
#mamba activate gh200

source /lustre/storeB/project/fou/hi/foccus/mateuszm/run-anemoi-ocean/ppi/.venv/bin/activate
RUN_DIR=/lustre/storeB/project/fou/hi/foccus/mateuszm/run-anemoi-ocean/ppi/
CONFIG_NAME=$RUN_DIR/template_configs/main-anemoi-infer.yaml

CONTAINER_SCRIPT=$RUN_DIR/run_pytorch_infer.sh

export HYDRA_FULL_ERROR=1
export AIFS_BASE_SEED=1337420
#singularity exec --nv -B /lustre/:/lustre/ $CONTAINER bash $CONTAINER_SCRIPT $CONFIG_NAME

bash $CONTAINER_SCRIPT $CONFIG_NAME

