#!/usr/bin/env python3
"""Extract all simple .classname selectors from styles.css"""
import re
from pathlib import Path

content = Path("content/css/styles.css").read_text()

classes = set()
# Match lines that start with a simple .classname (possibly comma-separated)
for line in content.splitlines():
    line = line.strip()
    if not line or line.startswith("//") or line.startswith("/*"):
        continue
    # Extract all .classname tokens from selector lines (lines ending with { or ,)
    if "{" in line or line.endswith(","):
        for match in re.finditer(r'^\.([\w-]+)(?:\s*[{,]|$)', line):
            classes.add(match.group(1))
        # Also handle comma-separated: .foo, .bar {
        for match in re.finditer(r',\s*\.([\w-]+)', line):
            classes.add(match.group(1))

for cls in sorted(classes):
    print(cls)
