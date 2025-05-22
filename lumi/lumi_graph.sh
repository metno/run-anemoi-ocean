#!/bin/bash
#SBATCH --output=outputs/%x_%j.out
#SBATCH --error=outputs/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --account=project_465001902
#SBATCH --partition=dev-g
#SBATCH --gpus-per-node=1
#SBATCH --time=01:00:00
#SBATCH --job-name=graph_creator
#SBATCH --exclusive

CONFIG_NAME=$(pwd -P)/template_configs/graph.yaml
GRAPH_NAME=$(pwd -P)/trim_edge_10_thinning_4_res_12.pt

#Should not have to change these
PROJECT_DIR=/pfs/lustrep3/scratch/$SLURM_JOB_ACCOUNT
CONTAINER_SCRIPT=$(pwd -P)/run_pytorch_graph.sh
chmod 770 ${CONTAINER_SCRIPT}
CONFIG_DIR=$(pwd -P)
# NB! in order to avoid NCCL timeouts it is adviced to use 
# pytorch 2.3.1 or above to have NCCL 2.18.3 version
CONTAINER=$PROJECT_DIR/container/ocean-ai-infer-pytorch-2.3.1-rocm-6.0.3-py-3.11.5-v0.0.sif
VENV=$(pwd -P)/.venv
export VIRTUAL_ENV=$VENV

module load LUMI/24.03 partition/G
# see https://docs.lumi-supercomputer.eu/hardware/lumig/
# see https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/lumig-job/

# New bindings see docs above. Correct ordering of cpu affinity
# excludes first and last core since they are not available 
# on GPU-nodes
CPU_BIND="mask_cpu:7e000000000000,7e00000000000000"
CPU_BIND="${CPU_BIND},7e0000,7e000000"
CPU_BIND="${CPU_BIND},7e,7e00"
CPU_BIND="${CPU_BIND},7e00000000,7e0000000000"

# run run-pytorch.sh in singularity container like recommended
# in LUMI doc: https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/p/PyTorch
srun --cpu-bind=$CPU_BIND \
    singularity exec -B /pfs:/pfs \
                     -B /var/spool/slurmd \
                     -B /opt/cray \
                     -B /usr/lib64 \
                     -B /opt/cray/libfabric/1.15.2.0/lib64/libfabric.so.1 \
        $CONTAINER $CONTAINER_SCRIPT $CONFIG_NAME $GRAPH_NAME