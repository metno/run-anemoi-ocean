CONTAINER=/pfs/lustrep2/scratch/project_465001629/container/ocean-ai.sif
export VIRTUAL_ENV="$(pwd -P)/.venv"
export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin
singularity exec --env PATH=$PATH -B /pfs:/pfs $CONTAINER anemoi-training mlflow login --url https://mlflow.ecmwf.int