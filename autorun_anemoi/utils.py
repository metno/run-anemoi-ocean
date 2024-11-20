import random
import re
import subprocess

from ruamel.yaml import YAML


def read_yaml(filename) -> dict:
    yaml = YAML(typ='safe')
    with open(filename, 'r') as f:
        dct = yaml.load(f)
    return dct

def dump_yaml(dct, filename) -> None:
    yaml=YAML()
    with open(filename, 'w') as f:
        yaml.dump(dct, f)

def time_str_to_sec(time_str) -> int:
    """Convert time string to seconds."""
    sec = 0
    if '-' in time_str:
        d, time_str = time_str.split('-')
        sec += int(d) * 24 * 60 * 60
    h, m, s = time_str.split(':')
    sec += int(h) * 60 * 60
    sec += int(m) * 60
    sec += int(s)
    return sec

def sec_to_time_str(s) -> str:
    """Convert seconds to time string."""
    m = s // 60
    h = m // 60
    d = h // 24
    s = s % 60
    m = m % 60
    h = h % 24
    if d > 0:
        return f'{d}-{h:0>2}:{m:0>2}:{s:0>2}'
    else:
        return f'{h:0>2}:{m:0>2}:{s:0>2}'

def file2str(filename) -> str:
    """Read file and return string."""
    with open(filename, 'r') as f:
        string = f.read()
    return string

def extend_filename(filename, i) -> str:
    """Extend filename with some variable i (usually an integer)."""
    filename = str(filename)
    splitted = filename.split('.')
    name = ''.join(splitted[:-1])
    ext = splitted[-1]
    return f'{name}_{i}.{ext}'

def build_jobscript(filename, job_dict, add_lines=[]) -> None:
    """Building a job script, given a dictionary of SBATCH commands,
    and optional additional lines appended to the file.

    Args:
        filename: str
            Filename and path of job script
        job_dict: dict
            Dictionary containing SBATCH commands to be added to the
            jobscript. If key is not associated with a value, put None
            as the value
        add_lines: list[str]
            Append lines to jobscript
    """
    with open(filename, 'w') as f:
        f.write('#!/bin/bash\n')
        for key, value in job_dict.items():
            if value is None or isinstance(value, str) and value.lower() == 'none':
                f.write(f'#SBATCH --{key}\n')
            else:
                f.write(f'#SBATCH --{key}={value}\n')
        f.write('\n')
        for line in add_lines:
            f.write(line + '\n')

def submit_jobscript(jobscript_name, **kwargs) -> int:
    """Submit jobscript and return job-ID.
    Additional SBATCH commands can be passed as arguments."""
    submit_list = ['sbatch']
    for key, value in kwargs.items():
        submit_list.append(f'--{key}={value}')
    submit_list.append(jobscript_name)

    output = subprocess.check_output(submit_list)
    job_id = int(re.findall("([0-9]+)", str(output))[0])

    # print to terminal
    out_text = f"Job submitted with job ID {job_id}"
    if 'dependency' in kwargs.keys():
        out_text += f" dependency: {kwargs['dependency']}"
    print(out_text)
    return job_id

def string_to_nested_dict(s):
    """Convert dot level-separated string to nested dict to
    represent the hierarchical structure.

    Example: 
    >>> string_to_nested_dict('model.num_channels=256')
    {'model': {'num_channels': 256}}
    """
    key_path, value = s.split('=')
    try:
        value = int(value)
    except ValueError:
        value = value.strip()
    keys = key_path.split('.')
    nested_dict = current_level = {}
    for key in keys[:-1]:
        current_level[key] = {}
        current_level = current_level[key]
    current_level[keys[-1]] = value
    return nested_dict

def get_random_name(filename):
    """Get random combination of noun and adjective taken from
    yaml file."""
    yaml = read_yaml(filename)
    adjective = random.choice(yaml['adjectives'])
    noun = random.choice(yaml['nouns'])
    return f'{adjective}_{noun}'
