#!/bin/bash

export VIRTUAL_ENV="$(pwd -P)/.venv"
if [ ! -d "$VIRTUAL_ENV" ]; then
    mkdir -p $VIRTUAL_ENV/lib $VIRTUAL_ENV/bin
fi

export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin

# Clone anemoi-core if not already cloned
if [ ! -d anemoi-core ]; then
    echo "Cloning anemoi-core"
    git clone git@github.com:ecmwf/anemoi-core.git
fi

# Install training, models, and graphs from anemoi-core
echo "Installing training, models, and graphs from anemoi-core"
pip install --user --no-deps -e anemoi-core/training
pip install --user --no-deps -e anemoi-core/models
pip install --user --no-deps -e anemoi-core/graphs

# Clone and install utils if not already cloned
if [ ! -d anemoi-utils ]; then
    echo "Cloning anemoi-utils"
    git clone git@github.com:ecmwf/anemoi-utils.git
fi
pip install --user --no-deps -e anemoi-utils

# Clone and install datasets if not already cloned
if [ ! -d anemoi-datasets ]; then
    echo "Cloning anemoi-datasets"
    git clone git@github.com:metno/anemoi-datasets.git
fi
pip install --user --no-deps -e anemoi-datasets
