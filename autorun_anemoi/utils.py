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
