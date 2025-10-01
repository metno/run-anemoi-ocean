#!/bin/bash

cd $(pwd -P)

# Make files executable in the container (might not be needed)
chmod 770 env_setup_infer.sh

PROJECT_DIR=/pfs/lustrep3/scratch/project_465002266
CONTAINER=$PROJECT_DIR/container/pytorch-2.7.0-rocm-6.2.4-py-3.12.9-v2.0.sif

# Clone and pip install anemoi repos from the container
singularity exec -B /pfs:/pfs $CONTAINER $(pwd -P)/env_setup_infer.sh
