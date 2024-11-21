from pathlib import Path

from autorun_anemoi.utils import *


class AutoRunAnemoi:
    """Run anemoi training automatized.
    Features:
        - Modify configuration files
        - Submit a sequence of jobs with dependencies
        - Save config and job script in temporary and overwrite-safe folder
    """
    def __init__(
            self, 
            base_yaml,
            job_yaml,
            total_time=None,
            max_time_per_job=None,
            inference_config=None,
            system='leonardo',
        ) -> None:
        """
        Args:
            base_yaml: str
                This is the main config, which might be modified
            job_yaml: str
                YAML file with SBATCH arguments to be used in job script.
            total_time: str
                Total run time given in D-HH:MM:SS format.
                Split into several jobs if exceeds max_time_per_job, which
                is the max run time of partition by default.
            max_time_per_job: str
                Maximum time per job, determines how many separate runs we get.
                Maximum allowed time by default.
            inference_config: str
                Inference config. If given, inference is executed after
                training.
            system: str
                Choose system to run on. This is needed to create jobscript
                and get default maximum time per job. leonardo | lumi | ppi
        """
        self.system = system.lower()
        self.total_time = total_time
        self.max_time_per_job = max_time_per_job
        self.base_yaml = base_yaml

        self.base_dict = self._check_type_yaml(base_yaml)
        self.job_dict = self._check_type_yaml(job_yaml)
        self._calc_time_per_run(total_time, max_time_per_job)

        # run inference
        self.run_inference = False
        if inference_config is not None:
            self.run_inference = True
            self.inference_dict = self._check_type_yaml(inference_config)

    def _check_type_yaml(self, yaml) -> dict:
        """Convert to dict of YAML file, just rename if already dict.
        May add other file formats as well (json?)."""
        if isinstance(yaml, str):
            splitted = yaml.split('.')
            ext = splitted[-1]
            assert ext.lower() in ['yaml', 'yml']
            return read_yaml(yaml)
        elif isinstance(yaml, dict):
            return yaml
        else:
            raise Exception("Config needs to be either a YAML file or dict")

    def modify_config(self, **kwargs) -> dict:
        """Command line arguments are used to overwrite config."""
        self.base_dict = merge(self.base_dict, kwargs)
        return self.base_dict

    def _calc_time_per_run(self, total_time, max_time_per_run) -> None:
        """Calculate execution time per run and the number of runs."""
        if self.system == 'leonardo':
            max_time = '1-00:00:00'
        elif self.system == 'lumi':
            max_time = '2-00:00:00'
        else:
            raise NotImplemented
        if total_time is None:
            try:
                total_time = self.job_dict['time']
            except KeyError:
                raise KeyError("Total time has to be specified in job config or throught the 'total_time' argument")
        if max_time_per_run is None:
            max_time_per_run = max_time
        total_time_sec = time_str_to_sec(total_time)
        max_time_per_run_sec = time_str_to_sec(max_time_per_run)
        max_time_sec = time_str_to_sec(max_time)
        if max_time_per_run_sec > max_time_sec:
            print(f"Max time per run exceeds max run time for paritition, setting max run time to {max_time}")
            max_time_per_run_sec = max_time_sec
        self.nrun = -(-total_time_sec // max_time_per_run_sec)
        time_per_run_sec = -(-total_time_sec // self.nrun)
        self.time_per_run = sec_to_time_str(time_per_run_sec)
        self.job_dict['time'] = self.time_per_run

    def _build_config(self, dct, filename) -> None:
        """Build config. Update paths to defaults if necessary."""
        if isinstance(self.base_yaml, str):
            path = '/'.join(self.base_yaml.split('/')[:-1])
            dct['hydra'] = {'searchpath': ['pkg://' + path]}
        dump_yaml(self.base_dict, filename)

    def __call__(self,
                 tmp_dir='tmp_dir',
                 jobscript_name='jobscript.sh',
                 config_name='config.yaml',
                 python_script='train.py',
                 inference_jobscript_name='inference.sh',
                 inference_config_name='inference.yaml',
                 inference_python_script='inference.py',
                 inference_job_yaml=None,
        ) -> None:
        """Run automatized framework. Generates a bunch of temporary files."""
        # set up correct paths
        path = Path(tmp_dir)
        path.mkdir(parents=True, exist_ok=True)
        jobscript_name = path / jobscript_name
        config_name = path / config_name
        inference_jobscript_name = path / inference_jobscript_name
        inference_config_name = path / inference_config_name
        autorun_path = __file__[:__file__.rfind('/')]

        # ensure that run_id is set, we need the name for dependency jobs
        run_id = self.base_dict['training']['run_id']
        if run_id is None:
            run_id = get_random_name(autorun_path +'/random_words/random_words_v1.yaml')
            #run_id = get_random_name('system_specific_cmds/lumi.sh')
            self.base_dict['training']['run_id'] = run_id
            print(f"run_id not defined, forced run-ID '{run_id}'")

        # build config and jobscript, and submit job
        self._build_config(self.base_dict, config_name)
        env_var = file2str(autorun_path + f'/system_specific_cmds/{self.system}.sh')
        env_var_tmp = env_var.format(python_script, config_name)
        build_jobscript(jobscript_name, self.job_dict, env_var_tmp.split('\n'))
        job_id = submit_jobscript(jobscript_name)

        # setting fork_run_id to run_id and rebuild config and jobscript
        self.base_dict['training']['fork_run_id'] = run_id
        self.base_dict['training']['load_weights_only'] = False
        config_name = extend_filename(config_name, 'dependency')
        self._build_config(self.base_dict, config_name)
        env_var_tmp = env_var.format(python_script, config_name)
        jobscript_name = extend_filename(jobscript_name, 'dependency')
        build_jobscript(jobscript_name, self.job_dict, env_var_tmp.split('\n'))

        # dependency jobs
        for i in range(1, self.nrun):
            sbatch_args = {
                    'output': extend_filename(self.job_dict['output'], i),
                    'error': extend_filename(self.job_dict['error'], i),
                    'dependency': f'afterany:{job_id}',
            }
            job_id = submit_jobscript(jobscript_name, **sbatch_args)

        # run inference if inference config is given
        if self.run_inference:
            max_epochs = self.base_dict['training']['max_epochs']
            self.inference_dict['experiment']['label'] = run_id
            self.inference_dict['experiment']['epoch'] = f'epoch_{max_epochs-1:0>3}'
            dump_yaml(self.inference_dict, inference_config_name)
            env_var_tmp = env_var.format(inference_python_script, inference_config_name)
            if inference_job_yaml is None:
                job_dict_tmp = self.job_dict
                job_dict_tmp['job-name'] += '_infer'
                job_dict_tmp['output'] = extend_filename(self.job_dict['output'], 'infer')
                job_dict_tmp['error'] = extend_filename(self.job_dict['error'], 'infer')
            else:
                job_dict_tmp = read_yaml(inference_job_yaml)
            build_jobscript(inference_jobscript_name, job_dict_tmp, env_var_tmp.split('\n'))
            submit_jobscript(inference_jobscript_name, dependency=f'afterany:{job_id}')
