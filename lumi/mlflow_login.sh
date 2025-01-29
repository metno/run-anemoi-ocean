CONTAINER=/pfs/lustrep2/scratch/project_465001629/container/ocean-ai.sif
singularity exec -B /pfs:/pfs $CONTAINER anemoi-training mlflow login --url https://mlflow.ecmwf.int