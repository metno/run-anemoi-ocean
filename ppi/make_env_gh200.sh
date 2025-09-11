#!/bin/bash
#SBATCH --job-name="MakeEnv"
#SBATCH --output=output/make_env.log
#SBATCH --gres=gpu:nvidia_gh200_480gb:1 
#SBATCH --partition=gpuB-arm-research
#SBATCH --time=10:00:00
#SBATCH --account=hi-training
#SBATCH --mem=200g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mateuszm@met.no
#SBATCH --ntasks-per-node=1

source /modules/rhel9/aarch64/mamba-mf3/etc/profile.d/ppimam.sh
mamba activate /home/mateuszm/.conda/envs/gh200-p3.11.5 ## --> Put global stuff into this env?

bash env_setup_core.sh

