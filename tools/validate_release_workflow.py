from pathlib import Path
import yaml

path = Path('.github/workflows/stream-browse-release-full.yml')
data = yaml.safe_load(path.read_text())
key_on = data.get('on', data.get(True))
assert key_on == ['workflow_dispatch'], key_on
assert set(data['jobs']) == {
    'verify', 'build_android', 'build_linux_x64', 'build_linux_arm64',
    'build_windows', 'build_macos', 'build_ios', 'release'
}
for job_name, job in data['jobs'].items():
    assert 'runs-on' in job, job_name
    assert 'steps' in job, job_name
print('workflow YAML valid; jobs:', ', '.join(data['jobs']))
