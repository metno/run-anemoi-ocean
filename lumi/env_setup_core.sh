#!/bin/bash

export VIRTUAL_ENV="$(pwd -P)/.venv"
if [ ! -d "$VIRTUAL_ENV" ]; then
    mkdir -p $VIRTUAL_ENV/lib $VIRTUAL_ENV/bin
fi

export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin

# Install core and datasets
for repo in core datasets; do
    if [ ! -d anemoi-$repo ]; then
        echo "Cloning anemoi-$repo"
        git clone git@github.com:metno/anemoi-$repo.git
    fi
    pip install --user --no-deps -e anemoi-$repo
done

# Install utils
if [ ! -d anemoi-utils ]; then
    echo "Cloning anemoi-utils"
    git clone git@github.com:ecmwf/anemoi-utils.git
fi
pip install --user --no-deps -e anemoi-utils