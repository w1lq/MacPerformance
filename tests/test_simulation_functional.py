import os
import sys
import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SIM_SCRIPT = PROJECT_ROOT / 'Simulation.py'
TOPO_FILE = PROJECT_ROOT / 'Topologies' / 'Cluster2.txt'
NOISE_FILE = PROJECT_ROOT / 'Noise' / 'meyer-heavy-short.txt'
STUB_DIR = Path(__file__).resolve().parent / 'stubs'

def test_simulation_runs(tmp_path):
    sim_dir = tmp_path / 'Simulation'
    sim_dir.mkdir()

    noise_copy = tmp_path / 'noise.txt'
    noise_copy.write_text(NOISE_FILE.read_text())

    env = os.environ.copy()
    existing = env.get('PYTHONPATH', '')
    env['PYTHONPATH'] = f"{STUB_DIR}{os.pathsep}{existing}" if existing else str(STUB_DIR)

    result = subprocess.run(
        [sys.executable, str(SIM_SCRIPT), '-g', str(TOPO_FILE), '-n', str(noise_copy)],
        cwd=tmp_path,
        env=env,
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0, result.stderr
    assert (sim_dir / 'Energy.txt').exists()
    assert (sim_dir / 'Packet.txt').exists()
    assert (sim_dir / 'Result.txt').exists()
