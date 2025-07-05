#!/bin/bash

export VIRTUAL_ENV="$(pwd -P)/.venv"
if [ ! -d "$VIRTUAL_ENV" ]; then
    mkdir -p $VIRTUAL_ENV/lib $VIRTUAL_ENV/bin
fi

export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin

#if [ ! -d bris-inference ]; then
#    echo "Cloning bris-inference"
#    git clone https://github.com/metno/bris-inference.git
#    cd bris-inference
#    git remote set-url origin git@github.com:metno/bris-inference.git
#    git reset --hard 48516e4999fa75e5146af70eb9186a9bd627919a # v0.2.0
#    cd ..
#fi
#pip install --user --no-deps -e bris-inference

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