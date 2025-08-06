import reframe as rfm
import reframe.utility.sanity as sn
import os

LICM_DEFAULT_ARGS="-C opt-level=3"
LICM_OWNSEM_ARGS = (
    "-C opt-level=3 "
    "-Cllvm-args=-licm-uses-ownsem "
    "-Cllvm-args=-licm-ownsem-safeset-ignores-throw "
    "-Cllvm-args=-licm-ownsem-safeset-store-threadsafe "
    "-Cllvm-args=-licm-ownsem-only-after-vectorization=false "
)

LICM_NO_LOAD_ONLY_ARGS = (
    "-C opt-level=3 "
    "-Cllvm-args=-licm-uses-ownsem=false "
    "-Cllvm-args=-licm-no-promote-load-only "
)

MEASUREMENT_TIME = 10  # Default measurement time in seconds

def artifact_projects():
    artifacts = os.getenv('ARTIFACTS')
    if artifacts:
        try:
            return [artifact.strip() for artifact in artifacts.split(';')]
        except ValueError:
            raise ValueError("ARTIFACTS environment variable must be in the format 'rel_dir1;rel_dir2;...' where rel_dir is relative to the artifacts directory.")
    return []

@rfm.simple_test
class CargoPerfOwnsemTest(rfm.RunOnlyRegressionTest):
    project = parameter(artifact_projects())
    valid_systems = ['*']
    valid_prog_environs = ['builtin']

    @run_before('run')
    def set_workdir(self):
        env_vars = 'RUSTFLAGS_DEFUALT_LICM="{default_licm}" RUSTFLAGS_OWNSEM_LICM="{ownsem_licm}"'.format(
            default_licm=LICM_DEFAULT_ARGS,
            ownsem_licm=LICM_OWNSEM_ARGS
        )
        self.prerun_cmds = [f'cd {self.stagedir}/artifacts/{self.project}']
        self.executable = f'{env_vars} bash perf_benchmark.sh'
        self.executable_opts = ['--measurement-time', str(MEASUREMENT_TIME)]
    
    @performance_function("geomean")
    def get_geomean(self):
        pattern = r'^Geometric Mean:\s*([0-9.]+)'
        match = sn.extractsingle(pattern, self.stdout, 1, float)
        return match
    
    @performance_function("%")
    def get_percent_improvement(self):
        pattern = r'^Percentage Improvement:\s*([0-9.-]+)'
        match = sn.extractsingle(pattern, self.stdout, 1, float)
        return match

    @sanity_function
    def assert_test_passed(self):
        return sn.assert_eq(self.job.exitcode, 0)

@rfm.simple_test
class CargoPerfNoLoadOnlyTest(rfm.RunOnlyRegressionTest):
    project = parameter(artifact_projects())
    valid_systems = ['*']
    valid_prog_environs = ['builtin']

    @run_before('run')
    def set_workdir(self):
        env_vars = 'RUSTFLAGS_DEFUALT_LICM="{default_licm}" RUSTFLAGS_NO_LOAD_ONLY_LICM="{no_load_only_licm}"'.format(
            default_licm=LICM_DEFAULT_ARGS,
            no_load_only_licm=LICM_NO_LOAD_ONLY_ARGS
        )
        self.prerun_cmds = [f'cd {self.stagedir}/artifacts/{self.project}']
        self.executable = f'{env_vars} bash perf_no_load_only_benchmark.sh'
        self.executable_opts = ['--measurement-time', str(MEASUREMENT_TIME)]
    
    @performance_function("geomean")
    def get_geomean(self):
        pattern = r'^Geometric Mean:\s*([0-9.]+)'
        match = sn.extractsingle(pattern, self.stdout, 1, float)
        return match
    
    @performance_function("%")
    def get_percent_improvement(self):
        pattern = r'^Percentage Improvement:\s*([0-9.-]+)'
        match = sn.extractsingle(pattern, self.stdout, 1, float)
        return match

    @sanity_function
    def assert_test_passed(self):
        return sn.assert_eq(self.job.exitcode, 0)
