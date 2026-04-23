#!/usr/bin/env python3
"""Post-tool hook: clears .next/cache when an image file is written or edited."""
import json
import os
import shutil
import sys

IMAGE_EXTENSIONS = ('.png', '.jpg', '.jpeg', '.webp', '.gif', '.svg', '.ico')

data = json.load(sys.stdin)
file_path = data.get('tool_input', {}).get('file_path', '')

if file_path.endswith(IMAGE_EXTENSIONS):
    # Walk up from the file to find the nearest .next/cache
    directory = os.path.dirname(file_path)
    while directory and directory != '/':
        cache_dir = os.path.join(directory, '.next', 'cache')
        if os.path.isdir(cache_dir):
            shutil.rmtree(cache_dir)
            print(f"Cleared {cache_dir}")
            break
        directory = os.path.dirname(directory)
