#!/bin/bash
#SBATCH --output=/scratch/project_465001383/aifs/logs/LOGNAME.out
#SBATCH --error=/scratch/project_465001383/aifs/logs/LOGNAME.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --account=project_465001383
#SBATCH --partition=standard-g
#SBATCH --gpus-per-node=8
#SBATCH --time=24:00:00
#SBATCH --job-name=aifs
#SBATCH --exclusive


#Change this
CONFIG_NAME=CONFIGNAME.yaml #This file should be located in run-anemoi/lumi

#Should not have to change these
PROJECT_DIR=/pfs/lustrep4/scratch/$SLURM_JOB_ACCOUNT
CONTAINER_SCRIPT=/pfs/lustrep4/$(pwd)/run_pytorch.sh
CONFIG_DIR=/pfs/lustrep4/$(pwd)
CONTAINER=$PROJECT_DIR/aifs/container/containers/anemoi-training-pytorch-2.2.2-rocm-5.6.1-py-3.11.5.sif
VENV=/pfs/lustrep4/$(pwd)/.venv
export VIRTUAL_ENV=$VENV

module load LUMI/23.09 partition/G
export SINGULARITYENV_LD_LIBRARY_PATH=/opt/ompi/lib:${EBROOTAWSMINOFIMINRCCL}/lib:/opt/cray/xpmem/2.4.4-2.3_9.1__gff0e1d9.shasta/lib64:${SINGULARITYENV_LD_LIBRARY_PATH}

# MPI + OpenMP bindings: https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/distribution-binding
CPU_BIND="mask_cpu:fe000000000000,fe00000000000000,fe0000,fe000000,fe,fe00,fe00000000,fe0000000000"

# run run-pytorch.sh in singularity container like recommended
# in LUMI doc: https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/p/PyTorch
srun --cpu-bind=$CPU_BIND \
    singularity exec -B /pfs:/pfs \
                     -B /var/spool/slurmd \
                     -B /opt/cray \
                     -B /usr/lib64 \
                     -B /usr/lib64/libjansson.so.4 \
        $CONTAINER $CONTAINER_SCRIPT $CONFIG_DIR $CONFIG_NAME

