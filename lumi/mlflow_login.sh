CONTAINER=/pfs/lustrep3/scratch/project_465002266/container/ocean-ai-pytorch-2.3.1-rocm-6.0.3-py-3.11.5-v0.0.sif
export VIRTUAL_ENV="$(pwd -P)/.venv"
export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin
singularity exec --env PATH=$PATH -B /pfs:/pfs $CONTAINER anemoi-training mlflow login --url https://mlflow.ecmwf.int