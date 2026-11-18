"""Build the standalone BAT from readable sources. Python standard library only."""
from pathlib import Path
import base64
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
config = json.loads((ROOT / 'scripts/patch.json').read_text(encoding='utf-8'))
payload = base64.b64encode(json.dumps(config, ensure_ascii=True).encode()).decode()
ps = (ROOT / 'scripts/patch.ps1').read_text(encoding='utf-8').replace('__PATCH_CONFIG__', payload)
header = '''@echo off
setlocal
title FlatOut 2 - R36S dArkOSen fix
set "FO2_FIX_SELF=%~f0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$text=[IO.File]::ReadAllText($env:FO2_FIX_SELF);$marker='#'+' POWERSHELL_PAYLOAD'; & ([scriptblock]::Create($text.Substring($text.IndexOf($marker)+$marker.Length)))"
set "FO2_FIX_RESULT=%errorlevel%"
echo.
if not "%~1"=="--no-pause" pause
exit /b %FO2_FIX_RESULT%
# POWERSHELL_PAYLOAD
'''
output = ROOT / 'downloads/fix-flatout2-r36s-darkosen.bat'
output.parent.mkdir(exist_ok=True)
output.write_bytes((header + ps).replace('\r\n', '\n').replace('\n', '\r\n').encode('ascii'))
(ROOT / 'downloads/SHA256SUMS.txt').write_text(hashlib.sha256(output.read_bytes()).hexdigest() + '  ' + output.name + '\n', encoding='ascii')
print(f'Built {output.name} ({output.stat().st_size} bytes)')
