#!/bin/bash
export HYDRA_FULL_ERROR=1
export AIFS_BASE_SEED=1337420

export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin
anemoi-training train --config-dir=$1 --config-name=$2

