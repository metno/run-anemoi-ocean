#!/bin/bash

export VIRTUAL_ENV="$(pwd -P)/.venv"
if [ ! -d "$VIRTUAL_ENV" ]; then
    mkdir -p $VIRTUAL_ENV/lib $VIRTUAL_ENV/bin
fi

export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin

for repo in datasets models training graphs; do
    if [ ! -d anemoi-$repo ]; then
        echo "Cloning $repo"
        git clone https://github.com/metno/anemoi-$repo.git
        cd anemoi-$repo
        git remote set-url origin git@github.com:metno/anemoi-$repo.git
        cd ..
    fi
    pip install --user --no-deps -e anemoi-$repo
done

cd anemoi-datasets
git checkout feature/trimedge
cd ..

for repo in utils; do
    if [ ! -d anemoi-$repo ]; then
        echo "Cloning $repo"
        git clone https://github.com/ecmwf/anemoi-$repo.git
        cd anemoi-$repo 
        git remote set-url origin git@github.com:ecmwf/anemoi-$repo.git
        cd ..
    fi
    pip install --user --no-deps -e anemoi-$repo
done

# Get the mlflow package to do offline sync
# Recomended way to install from README on GitHub
pip install git+https:///github.com/mlflow/mlflow-export-import/#egg=mlflow-export-import
