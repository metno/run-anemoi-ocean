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
    git reset --hard d5cf0113f3254cd431122b0923daadb0995f75ea # chore(main): Release 0.7.2 (#319)
    cd ..
fi

#echo "Installing anemoi-inference"
pip install --user -e anemoi-inference # consider adding dependencies to container later
