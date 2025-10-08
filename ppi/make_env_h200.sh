#!/bin/bash
#SBATCH --job-name="MakeEnv"
#SBATCH --output=output/make_env.log
#SBATCH --gres=gpu:nvidia_h200_nvl:1
#SBATCH --partition=gpuB-prod
#SBATCH --time=00:10:00
#SBATCH --account=hi-training
#SBATCH --mem=200g
#SBATCH --ntasks-per-node=1

source  /modules/rhel9/x86_64/mamba-mf3/etc/profile.d/ppimam.sh
mamba activate /home/mateuszm/.conda/envs/h200-p3.11.5 ## --> Put global stuff into this env?

bash env_setup.sh

