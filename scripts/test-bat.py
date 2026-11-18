"""Windows integration checks using user-supplied original/fixed launchers.

Usage: python scripts/test-bat.py ORIGINAL.sh FIXED.sh
Fixtures are created outside this repository and removed after success.
"""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
cfg = json.loads((ROOT/'scripts/patch.json').read_text())
old = Path(sys.argv[1]).read_bytes()
fixed = Path(sys.argv[2]).read_text(encoding='utf-8').replace('\r\n','\n')
bat = ROOT/'downloads/fix-flatout2-r36s-darkosen.bat'

def digest(b):
    return hashlib.sha256(b.decode('utf-8-sig').replace('\r\n','\n').replace('\r','\n').encode()).hexdigest()

assert digest(old) == cfg['before']
assert hashlib.sha256(fixed.encode()).hexdigest() == cfg['after']
temp = Path(tempfile.mkdtemp(prefix='flatout2-fix-tests-'))
try:
    def fixture(name, count=2, binary=True):
        # Spaces, ampersand, Unicode and literal bracket paths exercise Windows quoting.
        root = temp / (name + ' ports & ação [test]')
        (root/'flatout2').mkdir(parents=True)
        if binary: (root/'flatout2/fo2.aarch64').write_bytes(b'test fixture only')
        shutil.copyfile(bat, root/bat.name)
        for script in cfg['names'][:count]: (root/script).write_bytes(old)
        return root
    def run(root):
        return subprocess.run('cmd.exe /d /s /c ""' + str(root/bat.name) + '" --no-pause"', cwd=temp, capture_output=True)
    good = fixture('recognized')
    result = run(good)
    assert result.returncode == 0, (result.stdout + result.stderr).decode(errors='replace')
    backups = list((good/'flatout2').glob('backup-r36s-fix-*'))
    assert len(backups) == 1
    for name in cfg['names']:
        assert (backups[0]/name).read_bytes() == old
        assert (good/name).read_bytes() == fixed.encode()
        subprocess.run(['C:/Program Files/Git/bin/bash.exe','-n',str(good/name)], check=True)
    assert run(good).returncode == 0
    assert len(list((good/'flatout2').glob('backup-r36s-fix-*'))) == 1
    mixed = fixture('mixed unsupported')
    changed = old + b'\n# unrelated local edit\n'
    (mixed/cfg['names'][1]).write_bytes(changed)
    assert run(mixed).returncode != 0
    assert (mixed/cfg['names'][0]).read_bytes() == old
    assert (mixed/cfg['names'][1]).read_bytes() == changed
    assert not list((mixed/'flatout2').glob('backup-r36s-fix-*'))
    single = fixture('single', count=1)
    (single/cfg['names'][0]).write_bytes(b'\xef\xbb\xbf' + old.decode('utf-8').replace('\r\n','\n').replace('\n','\r\n').encode())
    assert run(single).returncode == 0
    assert (single/cfg['names'][0]).read_bytes() == fixed.encode()
    missing = fixture('missing directory', binary=False)
    assert run(missing).returncode != 0
    assert (missing/cfg['names'][0]).read_bytes() == old
    newer = fixture('new launcher',count=0)
    (newer/'FlatOut 2.sh').write_bytes(b'newer launcher fixture')
    assert run(newer).returncode != 0
    assert (newer/'FlatOut 2.sh').read_bytes() == b'newer launcher fixture'
    print('PASS: original pair, exact tested output, byte-for-byte backup, bash syntax, repeat run, atomic refusal, single launcher, BOM/CRLF, wrong folder, newer release, special Windows paths.')
except Exception:
    print(f'Failed fixtures retained for diagnosis: {temp}')
    raise
else:
    shutil.rmtree(temp)
