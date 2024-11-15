#!/bin/bash
#SBATCH --output=/scratch/project_465001383/aifs/logs/test-anemoi-training.out
#SBATCH --error=/scratch/project_465001383/aifs/logs/test-anemoi-training.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --account=project_465001383
#SBATCH --partition=dev-g
#SBATCH --gpus-per-node=8
#SBATCH --time=00:15:00
#SBATCH --job-name=aifs
#SBATCH --exclusive

echo "Setting paths"

PROJECT_DIR=/pfs/lustrep4/scratch/$SLURM_JOB_ACCOUNT
CONTAINER_SCRIPT=$PROJECT_DIR/haugenha/run-anemoi-setup/run-anemoi/lumi/run_pytorch.sh

#CHANGE THESE:
CONTAINER=$PROJECT_DIR/aifs/container/containers/aifs-met-pytorch-2.2.0-rocm-5.6.1-py3.9-v2.0-new-correct-anemoi-models-sort-vars.sif
PYTHON_SCRIPT=$PROJECT_DIR/YOUR_PATH/aifs-mono/train_netatmo.py
VENV=/pfs/lustrep4/$(pwd)/.venv

export VIRTUAL_ENV=$VENV

echo "module load"
module load LUMI/23.09 partition/G

echo "export singularity"
export SINGULARITYENV_LD_LIBRARY_PATH=/opt/ompi/lib:${EBROOTAWSMINOFIMINRCCL}/lib:/opt/cray/xpmem/2.4.4-2.3_9.1__gff0e1d9.shasta/lib64:${SINGULARITYENV_LD_LIBRARY_PATH}

# MPI + OpenMP bindings: https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/distribution-binding
CPU_BIND="mask_cpu:fe000000000000,fe00000000000000,fe0000,fe000000,fe,fe00,fe00000000,fe0000000000"

#if [[ "$VENV" != "None" && -n "$VENV" ]]; then
# Set this virtual environment
#    export VIRTUAL_ENV=$VENV

# Ensure the virtual environment is loaded inside the container
#    export PYTHONUSERBASE=$VIRTUAL_ENV
#    export PATH=$PATH:$VIRTUAL_ENV/bin
#else
#    :
#fi

echo "running srun"

# run run-pytorch.sh in singularity container like recommended
# in LUMI doc: https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/p/PyTorch
srun --cpu-bind=$CPU_BIND \
    singularity exec -B /pfs:/pfs \
                     -B /var/spool/slurmd \
                     -B /opt/cray \
                     -B /usr/lib64 \
                     -B /usr/lib64/libjansson.so.4 \
        $CONTAINER $CONTAINER_SCRIPT

