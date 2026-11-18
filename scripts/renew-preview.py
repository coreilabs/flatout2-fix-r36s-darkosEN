"""Create an immutable random-versioned copy of the original preview image."""
from pathlib import Path
import json
import secrets
import struct

root = Path(__file__).resolve().parents[1]
config_path = root / 'site.json'
config = json.loads(config_path.read_text(encoding='utf-8'))
original = root / config['image_original']
data = original.read_bytes()
if data[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('Expected the original PNG image.')
width, height = struct.unpack('>II', data[16:24])
target = original.with_name(original.stem + '-' + secrets.token_hex(8) + original.suffix)
target.write_bytes(data)
config.update(image=target.relative_to(root).as_posix(), image_width=width, image_height=height)
config_path.write_text(json.dumps(config, indent=2) + '\n', encoding='utf-8')
print('Preview image: ' + config['url'] + config['image'])
print('Run python scripts/build-docs.py and publish the HTML and image together.')
