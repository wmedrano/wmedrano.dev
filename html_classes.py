#!/usr/bin/env python3
"""Extract all unique class names from HTML files in ./public"""
import re
from pathlib import Path

classes = set()
for html_file in Path("public").rglob("*.html"):
    content = html_file.read_text(errors="ignore")
    for match in re.finditer(r'class="([^"]*)"', content):
        for cls in match.group(1).split():
            classes.add(cls)

for cls in sorted(classes):
    print(cls)
