#!/usr/bin/env python3
"""يحوّل ملفات SVG/HTML في branding/ إلى صور PNG. التشغيل:  python3 branding/render.py <name>"""
import sys, pathlib
from playwright.sync_api import sync_playwright

root = pathlib.Path(__file__).parent

def render(src, out, w, h, transparent=True):
    with sync_playwright() as p:
        b = p.chromium.launch()
        pg = b.new_page(viewport={"width": w, "height": h}, device_scale_factor=1)
        pg.goto((root / src).resolve().as_uri())
        pg.wait_for_timeout(300)
        pg.screenshot(path=str(out), omit_background=transparent)
        b.close()

if __name__ == "__main__":
    src, out, w, h = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
    render(src, pathlib.Path(out), w, h, transparent=(len(sys.argv) < 6 or sys.argv[5] != "opaque"))
