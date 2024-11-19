# Automatized running script for AnemoI
`autorun-anemoi` is a lightweight Python package for executing Anemoi production runs in an easy fashion. It supports chaining dependency jobs and modifying config on-the-fly. 

## Basic usage
`autorun-anemoi` comes with a command-line interface and a Python interface.

### Command-line interface

``` bash
autorun 20:00:00 aifs/config/config.yaml job.yaml
```

## Python interface

``` python
obj = AutoRunAnemoi('20:00:00', 'aifs/config/config.yaml', 'job.yaml')
obj()
```

## Install
``` bash
pip install .
```

## Modify config
Config modifications can be passed as command line arguments:

``` bash
for NCHANNELS in 256 512
do
    autorun 20:00:00 aifs/config/config.yaml job.yaml --model.num_channels=$NCHANNELS
done
```

## Run inference
Inference can be submitted as a dependency job, running when the last production job is finished. The inference config needs to be provided in order to invoke this operation:

``` bash
autorun 20:00:00 aifs/config/config.yaml job.yaml --inference_config=aifs/config/inference.yaml
```
