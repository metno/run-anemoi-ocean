#!/bin/bash

export VIRTUAL_ENV="$(pwd -P)/.venv"
if [ ! -d "$VIRTUAL_ENV" ]; then
    mkdir -p $VIRTUAL_ENV/lib $VIRTUAL_ENV/bin
fi

export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin

# Clone anemoi-core if not already cloned
if [ ! -d anemoi-core ]; then
    echo "Cloning anemoi-core from ecmwf"
    git clone --branch main https://github.com/ecmwf/anemoi-core.git
    cd anemoi-core
    git remote set-url origin git@github.com:ecmwf/anemoi-core.git
    git reset --hard 26f2d92d77fe341459fde722f2e9b965751c47ce #chore(main): Release models 0.7.0 (#324)
    cd ..
fi

# Install training, models, and graphs from anemoi-core
echo "Installing training, models, and graphs from anemoi-core"
pip install --user --no-deps -e anemoi-core/training
pip install --user --no-deps -e anemoi-core/models
pip install --user --no-deps -e anemoi-core/graphs

# Clone and install utils if not already cloned
if [ ! -d anemoi-utils ]; then
    echo "Cloning anemoi-utils from ecmwf"
    git clone https://github.com/ecmwf/anemoi-utils.git
    cd anemoi-utils
    git remote set-url origin git@github.com:ecmwf/anemoi-utils.git
    cd ..
fi
pip install --user --no-deps -e anemoi-utils

# Clone and install datasets if not already cloned
if [ ! -d anemoi-datasets ]; then
    echo "Cloning anemoi-datasets from metno"
    #git clone https://github.com/metno/anemoi-datasets.git
    git clone https://github.com/ecmwf/anemoi-datasets.git
    cd anemoi-datasets
    git remote set-url origin git@github.com:metno/anemoi-datasets.git
    git reset --hard 7fe6eb0a1d816ff409ddc61bacc737af7d2e7de2 # commit chore(main): Release 0.5.21
    cd ..
fi
pip install --user --no-deps -e anemoi-datasets

# Get the mlflow package to do offline sync
# Recomended way to install from README on GitHub
pip install git+https:///github.com/mlflow/mlflow-export-import/#egg=mlflow-export-import
