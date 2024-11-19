from autorun_anemoi import AutoRunAnemoi
import argparse

def get_parser():
    parser = argparse.ArgumentParser(description="Automatized execution of AnemoI runs")
    parser.add_argument('total_time', type=str, help='Expected total execution time, splitted across several jobs if needed. Format: D-HH-MM-SS or HH-MM-SS')
    parser.add_argument('config', type=str, help='Path to main config')
    parser.add_argument('job_yaml', type=str, help='Path to yaml file containing sbatch commands')
    parser.add_argument('-m', '--max_time_per_job', type=str, default=None, help='Maximum execution time per job. Format: D-HH-MM-SS or HH-MM-SS')
    parser.add_argument('-i', '--inference_config', type=str, default=None, help='Inference config file. Will start inference dependency job if given')
    parser.add_argument('--tmp_dir', type=str, default='tmp_dir', help='Path to temporary dir containing modified config, jobscripts etc..')
    parser.add_argument('--python_script', type=str, default='train.py', help='Python script to be executed')
    parser.add_argument('--inference_python_script', type=str, default='inference.py', help='Inference Python script to be executed')
    return parser

def string_to_nested_dict(s):
    # Split the string into key path and value
    key_path, value = s.split('=')
    # Convert the value to appropriate type
    try:
        value = int(value)
    except ValueError:
        value = value.strip()

    # Split the key path into keys
    keys = key_path.split('.')

    # Create the nested dictionary
    nested_dict = current_level = {}
    for key in keys[:-1]:
        current_level[key] = {}
        current_level = current_level[key]
    current_level[keys[-1]] = value

    return nested_dict


def run():
    args, unknown = get_parser().parse_known_args()

    unknown_dct = {}
    for element in unknown:
        dct = string_to_nested_dict(element)
        unknown_dct = unknown_dct | dct

    obj = AutoRunAnemoi(args.total_time,
                        args.config,
                        args.job_yaml,
                        max_time_per_job=args.max_time_per_job,
                        inference_yaml=args.inference_config)

    obj.modify_dict(**unknown_dct)
    obj(tmp_dir=args.tmp_dir,
        python_script=args.python_script,
        inference_python_script=args.inference_python_script)
