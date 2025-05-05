
PROJECT_DIR=/pfs/lustrep3/scratch/project_465001902
SOURCE=$PROJECT_DIR/experiments/mlflow-test/logs/mlflow/ #INSERT SOURCE PATH f.ex output/logs/mlflow/
RUNID=0b41c204fc7d409e8d4f110ae111426c # run-id of the run f.ex dca82f0b235542d1bc4e4c8fcdcb71a1

CONTAINER=$PROJECT_DIR/container/ocean-ai-pytorch-2.3.1-rocm-6.0.3-py-3.11.5-v0.0.sif
export VIRTUAL_ENV="$(pwd -P)/.venv"

export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin

export SCRATCH=$SOURCE

PYTHONUSERBASE="/" singularity exec --env PATH=$PATH \
    --env PYTHONUSERBASE=$PYTHONUSERBASE -B /pfs:/pfs \
    $CONTAINER anemoi-training mlflow sync \
    --source $SOURCE \
    --destination https://mlflow.ecmwf.int \
    -a \
    --run-id $RUNID \
    --experiment-name metno-fou \
    --verbose