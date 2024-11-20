# Automatized AnemoI training with SLURM
`autorun-anemoi` is a lightweight Python package for submitting Anemoi training runs to the SLURM queue.

Features:
- Chained dependency jobs for long training
- Auto-run inference after training is finalised
- Modify config on-the-fly for efficient testing
- Back ups config and jobscript to avoid overwriting

## Install
This package is not available on PyPi. To install, run:
``` bash
pip install git+https://github.com/metno/run-anemoi.git
```

## Basic usage
`autorun-anemoi` comes with a command-line interface and a Python interface. The examples will focus on the command-line interface, but the python interface has the same support. 

### Command-line interface
The command-line interface comes with two required arguments: `config-name` and `sbatch-yaml`:

``` bash
run-anemoi <config-name> <sbatch-yaml>
```
The first is the path to the config to be used, and the second is a `YAML`-file containing all SBATCH commands to be used in the job script. An example file can be found as [job.yaml](job.yaml):
``` yaml
output: output.out
error: error.err
nodes: 1
ntasks-per-node: 4
gpus-per-node: 4
mem: 450G
account: DestE_330_24
partition: boost_usr_prod
job-name: test
exclusive: None
```

``` bash
run-anemoi anemoi/config/config.yaml job.yaml
```

### Python interface
The same operation can be done by creating an `AutoRunAnemoi`-object in Python:

``` python
from autorun_anemoi import AutoRunAnemoi

obj = AutoRunAnemoi('aifs/config/config.yaml', 'job.yaml')
obj()
```

## Chained jobs
If total training time is longer than what is practical for a single job (due to system limitations or queue times), multiple dependency jobs can be submitted. This happens if the `total_time`, which is the expected time for the training procedure specified in the config, exceeds the `max_time_per_job`. Set `total_time` with the `--total_time` or `-t` argument (follows the SLURM time format):

``` bash
run-anemoi anemoi/config/config.yaml job.yaml -t 3-00:00:00
```

The default `max_time_per_job` is set to the maximum running time for the specified partition. To override this, use the `--max_time_per_job` or `-m` argument:

``` bash
run-anemoi anemoi/config/config.yaml job.yaml -t 3-00:00:00 -m 12:00:00
```
The command above will submit 6 jobs in total (one initial job and five dependency jobs), each with a total time of 12 hours.

## Running inference
We can also run inference after training is finalised. Similar to the training job, the inference job needs a config name and a sbatch yaml, which can be specified by `--inference_config_name` (`-i`) or `--inference_job_yaml` (`-j`), respectively:

``` bash
run-anemoi anemoi/config/config.yaml job.yaml -i inference.yaml -j inference_job.yaml
```
Use the argument `--inference_python_script` to change name of the inference script from `inference.py`.


## Modifying config on-the-fly
Config overrides can be passed as command line arguments:
``` bash
run-anemoi anemoi/config/config.yaml job.yaml diagnostics.plot.enabled=False
```

This is in particular useful if we want to submit a series of experiments with just small changes in the config:
``` bash
for NCHANNELS in 256 512
do
    run-anemoi aifs/config/config.yaml job.yaml model.num_channels=$NCHANNELS
done
```
In python, use the `modify_config`-method:

``` python
from autorun_anemoi import AutoRunAnemoi

obj = AutoRunAnemoi('aifs/config/config.yaml', 'job.yaml')
for i in [256, 512]:
	obj.modify_config(f'model.num_channels={i}')
	obj()
```

## Help
``` bash
run-anemoi --help
```
