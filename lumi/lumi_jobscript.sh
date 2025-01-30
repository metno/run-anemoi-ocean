#!/bin/bash
#SBATCH --output=outputs/output.o%j
#SBATCH --error=outputs/error.e%j
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --account=project_465001629
#SBATCH --partition=standard-g
#SBATCH --gpus-per-node=8
#SBATCH --time=00:20:00
#SBATCH --job-name=ocean-ai-mlflow
#SBATCH --exclusive

CONFIG_NAME=main.yaml 

#Should not have to change these
PROJECT_DIR=/pfs/lustrep2/scratch/$SLURM_JOB_ACCOUNT
CONTAINER_SCRIPT=$(pwd -P)/run_pytorch.sh
CONFIG_DIR=$(pwd -P)
CONTAINER=$PROJECT_DIR/container/ocean-ai.sif
VENV=$(pwd -P)/.venv # use venv installed in this dir
export VIRTUAL_ENV=$VENV

module load LUMI/24.03 partition/G
# not needed for interconnect
#export SINGULARITYENV_LD_LIBRARY_PATH=/opt/ompi/lib:${EBROOTAWSMINOFIMINRCCL}/lib:/opt/cray/xpmem/2.4.4-2.3_9.1__gff0e1d9.shasta/lib64:${SINGULARITYENV_LD_LIBRARY_PATH}

# MPI + OpenMP bindings: https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/distribution-binding
CPU_BIND="mask_cpu:fe000000000000,fe00000000000000,fe0000,fe000000,fe,fe00,fe00000000,fe0000000000"

# run run-pytorch.sh in singularity container like recommended
# in LUMI doc: https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/p/PyTorch
srun --cpu-bind=$CPU_BIND \
    singularity exec -B /pfs:/pfs \
                     -B /var/spool/slurmd \
                     -B /opt/cray \
                     -B /usr/lib64 \
        $CONTAINER $CONTAINER_SCRIPT $CONFIG_DIR $CONFIG_NAME
