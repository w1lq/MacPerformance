import subprocess
import sys


def test_simulation_import_error():
    result = subprocess.run([sys.executable, 'Simulation.py'], capture_output=True, text=True)
    assert 'No module named' in result.stderr
