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
    git reset --hard 801c500b00e6381b796d398db8068c25371ec5c1 # chore: Release main (#505)
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
    git reset --hard 83bb7262238fd8c20f0b6fdcf75d67bcfdb2d1db # chore(main): Release 0.5.26 (#343)
    cd ..
fi
pip install --user --no-deps -e anemoi-datasets

# Get the mlflow package to do offline sync
# Recomended way to install from README on GitHub
pip install git+https:///github.com/mlflow/mlflow-export-import/#egg=mlflow-export-import

if [ ! -d anemoi-transform ]; then
    git clone https://github.com/ecmwf/anemoi-transform.git
    cd anemoi-transform
    git remote set-url origin git@github.com:ecmwf/anemoi-transform.git
    git reset --hard c602c0fd428bb7f48b8868a8e2b6a87cdf4b9c80 # chore(main): release 0.1.16 (#149)
    cd ..
fi 

pip install --user --no-deps -e anemoi-transform

cp lam.yaml ./anemoi-core/training/src/anemoi/training/config/training/scalers/
cat ./anemoi-core/training/src/anemoi/training/config/training/scalers/lam.yaml | grep tendency

if [ ! -d anemoi-inference ]; then
    echo "Cloning anemoi-inference from ecmwf"
    git clone https://github.com/ecmwf/anemoi-inference.git
    cd anemoi-inference
    git remote set-url origin git@github.com:ecmwf/anemoi-inference.git
    git reset --hard c02c45aa1329fdc0c660ee2d7eccac2b15bc0514 # working version with current runner.py
    echo "Copying runner.py to anemoi-inference/src/anemoi/inference/ to avoid cuda-bug"
    cp ../runner.py ./src/anemoi/inference/
    cat ./src/anemoi/inference/runner.py | grep cuda
    cd ..
fi

#echo "Installing anemoi-inference"
pip install --user -e anemoi-inference # consider adding dependencies to container later

echo "Did the runner.py copy work?"
cat ./anemoi-inference/src/anemoi/inference/runner.py | grep cuda
