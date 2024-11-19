PROJECT_DIR=$WORK

export HYDRA_FULL_ERROR=1
export NCCL_DEBUG=WARN #INFO

module load profile/deeplrn
module load cineca-ai/4.3.0

# Print SMI statistics for first node
if [ $SLURM_LOCALID -eq 0 ] ; then
	srun nvidia-smi
fi

# Load Python virtual environment
source $PROJECT_DIR/anemoi/python-environment/anemoi_env/bin/activate

srun python3 {} {}
