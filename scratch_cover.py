import subprocess
import xml.etree.ElementTree as ET

res = subprocess.run(['pdftotext', '-f', '1', '-l', '1', '-bbox-layout', 'src/build/main.pdf', '-'], capture_output=True)
root = ET.fromstring(res.stdout)
ns = {'h': 'http://www.w3.org/1999/xhtml'}
for page in root.iter('{http://www.w3.org/1999/xhtml}page'):
    print('Page width:', page.get('width'), 'height:', page.get('height'))
prev_ymax = 0.0
for b in root.iter('{http://www.w3.org/1999/xhtml}block'):
    words = [w.text for w in b.iter('{http://www.w3.org/1999/xhtml}word') if w.text]
    text = ' '.join(words)
    if text.strip():
        ymin = float(b.get('yMin'))
        ymax = float(b.get('yMax'))
        gap = ymin - prev_ymax if prev_ymax > 0 else 0
        print(f"ymin={ymin:6.1f}, ymax={ymax:6.1f}, h={ymax-ymin:5.1f}, gap_above={gap:5.1f} | {text}")
        prev_ymax = ymax
