CONTAINER=/pfs/lustrep4/scratch/project_465001629/container/ocean-ai-trimedge.sif
singularity exec -B /pfs:/pfs $CONTAINER anemoi-training mlflow login --url https://mlflow.ecmwf.int