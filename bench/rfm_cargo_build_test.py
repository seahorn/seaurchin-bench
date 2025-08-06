import reframe as rfm
import reframe.utility.sanity as sn
import reframe.utility.udeps as udeps
import os
from pathlib import Path

LICM_OWNSEM_ARGS = (
    "-Cllvm-args=-licm-uses-ownsem "
    "-Cllvm-args=-licm-ownsem-safeset-ignores-throw "
    "-Cllvm-args=-licm-ownsem-safeset-store-threadsafe "
    "-Cllvm-args=-licm-ownsem-only-after-vectorization=false"
)

LICM_NO_LOAD_ONLY_ARGS = (
    "-C opt-level=3 "
    "-Cllvm-args=-licm-uses-ownsem=false "
    "-Cllvm-args=-licm-no-promote-load-only "
)

def artifact_projects():
    artifacts = os.getenv('ARTIFACTS')
    if artifacts:
        try:
            return [artifact.strip() for artifact in artifacts.split(';')]
        except ValueError:
            raise ValueError("ARTIFACTS environment variable must be in the format 'rel_dir1;rel_dir2;...' where rel_dir is relative to the artifacts directory.")
    return []

class CargoBuildSeaurchinBase(rfm.RunOnlyRegressionTest):
    @performance_function("alias-sets")
    def get_load_store_promotions(self):
        pattern = r'^\s*(\d+)\s+licm.*Number of load and store promotions'
        matches = sn.extractall(pattern, self.stdout, 1)
        total = sn.evaluate(sn.sum([int(x) for x in matches]))
        return total
    
    @performance_function("alias-sets")
    def get_load_only_promotions(self):
        pattern = r'^\s*(\d+)\s+licm.*Number of load-only promotions'
        matches = sn.extractall(pattern, self.stdout, 1)
        total = sn.evaluate(sn.sum([int(x) for x in matches]))
        return total

    @performance_function("reg-spills")
    def get_num_of_reg_spills(self):
        pattern = r'^\s*(\d+)\s+regalloc.*Number of spills inserted'
        matches = sn.extractall(pattern, self.stdout, 1)
        total = sn.evaluate(sn.sum([int(x) for x in matches]))
        return total

    @performance_function("loops")
    def get_loops_vectorized(self):
        pattern = r'^\s*(\d+)\s+loop-vectorize.*Number of loops vectorized'
        matches = sn.extractall(pattern, self.stdout, 1)
        total = sn.evaluate(sn.sum([int(x) for x in matches]))
        return total

    @performance_function("inst")
    def get_num_vec_instruc_gen(self):
        pattern = r'^\s*(\d+)\s+SLP.*Number of vector instructions generated'
        matches = sn.extractall(pattern, self.stdout, 1)
        total = sn.evaluate(sn.sum([int(x) for x in matches]))
        return total

@rfm.simple_test
class CargoBuildSeaurchinOwnsemTest(CargoBuildSeaurchinBase):
    project = parameter(artifact_projects())
    valid_systems = ['local:ownsem']
    valid_prog_environs = ['builtin']

    @run_before('run')
    def set_workdir(self):
        rustflags = '-C opt-level=3 -Zprint_codegen_stats ' + LICM_OWNSEM_ARGS
        self.prerun_cmds = [f'cd {self.stagedir}/artifacts/{self.project}']
        self.executable = f'RUSTFLAGS="{rustflags}" cargo'
        self.executable_opts = ['build-with-seaurchin']

    @sanity_function
    def assert_test_passed(self):
        return sn.assert_eq(self.job.exitcode, 0)

@rfm.simple_test
class CargoBuildSeaurchinDefaultTest(CargoBuildSeaurchinBase):
    project = parameter(artifact_projects())
    valid_systems = ['local:default']
    valid_prog_environs = ['builtin']

    @run_before('run')
    def set_workdir(self):
        rustflags = '-C opt-level=3   -Zprint_codegen_stats'
        self.prerun_cmds = [f'cd {self.stagedir}/artifacts/{self.project}']
        self.executable = f'RUSTFLAGS="{rustflags}" cargo'
        self.executable_opts = ['build-with-seaurchin']

    @sanity_function
    def assert_test_passed(self):
        return sn.assert_eq(self.job.exitcode, 0)

@rfm.simple_test
class CargoBuildSeaurchinLoadOnlyTest(CargoBuildSeaurchinBase):
    project = parameter(artifact_projects())
    valid_systems = ['local:load-only']
    valid_prog_environs = ['builtin']

    @run_before('run')
    def set_workdir(self):
        rustflags = '-C opt-level=3 -Zprint_codegen_stats ' + LICM_NO_LOAD_ONLY_ARGS
        self.prerun_cmds = [f'cd {self.stagedir}/artifacts/{self.project}']
        self.executable = f'RUSTFLAGS="{rustflags}" cargo'
        self.executable_opts = ['build-with-seaurchin']

    @sanity_function
    def assert_test_passed(self):
        return sn.assert_eq(self.job.exitcode, 0)


@rfm.simple_test
class CargoTestSeaurchinOwnsemTest(rfm.RunOnlyRegressionTest):
    project = parameter(artifact_projects())
    valid_systems = ['local:ownsem']
    valid_prog_environs = ['builtin']

    @run_after('init')
    def set_dependency(self):
      # Create dependency on BuildTest with the same project
      self.depends_on('CargoBuildSeaurchinOwnsemTest',
                      how=lambda child, parent: child[0] == parent[0])

    @run_before('run')
    def set_workdir(self):
      rustflags = '-C opt-level=3 ' + LICM_OWNSEM_ARGS
      self.prerun_cmds = [f'cd {self.stagedir}/artifacts/{self.project}']
      self.executable = 'RUSTFLAGS="{}" cargo'.format(rustflags)
      self.executable_opts = ['test-with-seaurchin']

    @sanity_function
    def assert_test_passed(self):
      return sn.assert_eq(self.job.exitcode, 0)
    
@rfm.simple_test
class CargoTestSeaurchinDefaultTest(rfm.RunOnlyRegressionTest):
    project = parameter(artifact_projects())
    valid_systems = ['local:default']
    valid_prog_environs = ['builtin']

    @run_after('init')
    def set_dependency(self):
      # Create dependency on BuildTest with the same project
      self.depends_on('CargoBuildSeaurchinDefaultTest', 
                      how=lambda child, parent: child[0] == parent[0])

    @run_before('run')
    def set_workdir(self):
      rustflags = '-C opt-level=3'
      self.prerun_cmds = [f'cd {self.stagedir}/artifacts/{self.project}']
      self.executable = 'RUSTFLAGS="{}" cargo'.format(rustflags)
      self.executable_opts = ['test-with-seaurchin']

    @sanity_function
    def assert_test_passed(self):
      return sn.assert_eq(self.job.exitcode, 0)

@rfm.simple_test
class CargoTestSeaurchinLoadOnlyTest(rfm.RunOnlyRegressionTest):
    project = parameter(artifact_projects())
    valid_systems = ['local:load-only']
    valid_prog_environs = ['builtin']

    @run_after('init')
    def set_dependency(self):
      # Create dependency on BuildTest with the same project
      self.depends_on('CargoBuildSeaurchinLoadOnlyTest', 
                      how=lambda child, parent: child[0] == parent[0])

    @run_before('run')
    def set_workdir(self):
      rustflags = '-C opt-level=3 ' + LICM_NO_LOAD_ONLY_ARGS
      self.prerun_cmds = [f'cd {self.stagedir}/artifacts/{self.project}']
      self.executable = 'RUSTFLAGS="{}" cargo'.format(rustflags)
      self.executable_opts = ['test-with-seaurchin']

    @sanity_function
    def assert_test_passed(self):
      return sn.assert_eq(self.job.exitcode, 0)