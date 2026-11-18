"""Run after CSS edits: create a random publication token and update both pages."""
from pathlib import Path
import re
import secrets
import json
root = Path(__file__).resolve().parents[1]
token = secrets.token_hex(8)
config_path = root / 'site.json'
config = json.loads(config_path.read_text(encoding='utf-8'))
config['css_version'] = token
config_path.write_text(json.dumps(config, indent=2) + '\n', encoding='utf-8')
for page in (root / 'index.html', root / 'pt-br/index.html'):
    text = page.read_text(encoding='utf-8')
    text, count = re.subn(r'(assets/style\.css)(?:\?v=[a-f0-9]+)?', rf'\1?v={token}', text)
    if count != 1:
        raise SystemExit(f'Expected one CSS reference in {page}')
    page.write_text(text, encoding='utf-8', newline='\n')
print(f'CSS publication token: {token}')
