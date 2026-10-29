#!/usr/bin/env python3
"""يولّد شعار Zool OS وطبقاته (للأنيميشن) وكلمة الشعار.

الفكرة: أهرامات مروي + شمس السودان + التقاء النيلين (الأزرق والأبيض) عند المقرن.

المتطلبات:  pip install uharfbuzz fonttools brotli playwright
            npm i @fontsource/outfit @fontsource/reem-kufi   (داخل مجلد branding/)
الاستعمال:  python3 branding/make_logo.py
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from zoolbrand import PALETTE as C, font_ttf, text_path, render_svg, HERE  # noqa: E402

ROOT = os.path.dirname(HERE)
LOGO_DIR = os.path.join(ROOT, "profile/airootfs/usr/share/zool/logo")
PLY_DIR = os.path.join(ROOT, "profile/airootfs/usr/share/plymouth/themes/zool")
SRC_DIR = os.path.join(HERE, "src")
for d in (LOGO_DIR, PLY_DIR, SRC_DIR):
    os.makedirs(d, exist_ok=True)

FS = os.environ.get("ZOOL_FONTSOURCE", os.path.join(HERE, "node_modules/@fontsource"))
OUTFIT = font_ttf(f"{FS}/outfit/files/outfit-latin-700-normal.woff")
KUFI = font_ttf(f"{FS}/reem-kufi/files/reem-kufi-arabic-700-normal.woff")

SUN = (256, 285)   # مركز الشمس داخل الشعار


def svg(inner, w=512, h=512, defs=""):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
            f'<defs>{defs}</defs>{inner}</svg>')


# ── الطبقات ────────────────────────────────────────────────
SKY_DEFS = f'''
<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
  <stop offset="0" stop-color="#14303b"/>
  <stop offset="0.45" stop-color="#3d4752"/>
  <stop offset="0.72" stop-color="#a8624a"/>
  <stop offset="1" stop-color="{C["gold"]}"/>
</linearGradient>'''
SKY = '<circle cx="256" cy="256" r="226" fill="url(#sky)"/>'


def rays_markup(cx, cy):
    out = []
    for i in range(24):
        a = i * 15
        tip = 140 if i % 2 == 0 else 124
        out.append(f'<polygon points="104,-5 {tip},0 104,5" fill="{C["gold"]}" opacity="{0.95 if i % 2 == 0 else 0.75}" '
                   f'transform="translate({cx} {cy}) rotate({a})"/>')
    return "".join(out)


RAYS = rays_markup(256, 256)          # مركّزة في اللوحة (للدوران في Plymouth)
RAYS_LOGO = rays_markup(*SUN)

SUN_DEFS = f'''
<radialGradient id="sunfill" cx="0.5" cy="0.4" r="0.7">
  <stop offset="0" stop-color="#fff0c4"/>
  <stop offset="0.55" stop-color="{C["gold"]}"/>
  <stop offset="1" stop-color="{C["terracotta"]}"/>
</radialGradient>
<radialGradient id="glow" cx="0.5" cy="0.5" r="0.5">
  <stop offset="0" stop-color="{C["gold"]}" stop-opacity="0.55"/>
  <stop offset="1" stop-color="{C["gold"]}" stop-opacity="0"/>
</radialGradient>'''


def sun_markup(cx, cy):
    return (f'<circle cx="{cx}" cy="{cy}" r="150" fill="url(#glow)"/>'
            f'<circle cx="{cx}" cy="{cy}" r="92" fill="url(#sunfill)"/>')


SUN_L = sun_markup(*SUN)


def pyramid(cx, base, w, h, dark, light):
    hw = w / 2
    courses = "".join(
        f'<line x1="{cx - hw * (1 - k / 7):.1f}" y1="{base - k * h / 7:.1f}" x2="{cx + hw * (1 - k / 7):.1f}" '
        f'y2="{base - k * h / 7:.1f}" stroke="#2a1a14" stroke-opacity="0.28" stroke-width="1.6"/>'
        for k in range(1, 7))
    return (f'<polygon points="{cx - hw},{base} {cx},{base - h} {cx},{base}" fill="{dark}"/>'
            f'<polygon points="{cx},{base - h} {cx + hw},{base} {cx},{base}" fill="{light}"/>' + courses)


LAND_DEFS = f'''
<clipPath id="disc"><circle cx="256" cy="256" r="226"/></clipPath>
<linearGradient id="dune" x1="0" y1="0" x2="0" y2="1">
  <stop offset="0" stop-color="#e8c27a"/>
  <stop offset="1" stop-color="#b9783f"/>
</linearGradient>
<linearGradient id="merge" x1="0" y1="0" x2="1" y2="0">
  <stop offset="0" stop-color="{C["nile_blue"]}"/>
  <stop offset="0.5" stop-color="{C["teal"]}"/>
  <stop offset="1" stop-color="#e9efe6"/>
</linearGradient>'''

LAND = f'''
<g clip-path="url(#disc)">
  <path d="M0 338 C80 322 170 348 256 340 S430 324 512 338 L512 512 L0 512 Z" fill="url(#dune)"/>
  {pyramid(160, 342, 78, 96, "#6d3324", "#c4643c")}
  {pyramid(352, 342, 78, 96, "#6d3324", "#c4643c")}
  {pyramid(256, 346, 100, 124, "#7a3a28", "#d8794a")}
  <path d="M0 372 C100 366 205 392 256 452" fill="none" stroke="{C["nile_blue"]}" stroke-width="30" stroke-linecap="butt"/>
  <path d="M512 372 C412 366 307 392 256 452" fill="none" stroke="#efe6d2" stroke-width="30" stroke-linecap="butt"/>
  <path d="M0 372 C100 366 205 392 256 452" fill="none" stroke="#7cc0dc" stroke-width="3" stroke-opacity="0.7" transform="translate(0 -4)"/>
  <path d="M512 372 C412 366 307 392 256 452" fill="none" stroke="#ffffff" stroke-width="3" stroke-opacity="0.8" transform="translate(0 -4)"/>
  <path d="M222 444 Q256 432 290 444 L318 524 L194 524 Z" fill="url(#merge)"/>
</g>'''

RING = f'''
<circle cx="256" cy="256" r="240" fill="none" stroke="{C["sand"]}" stroke-width="10"/>
<circle cx="256" cy="256" r="229" fill="none" stroke="{C["gold"]}" stroke-width="2.5"/>
''' + "".join(
    f'<rect x="-9" y="-9" width="18" height="18" fill="{C["gold"]}" transform="translate({256 + 240 * math.cos(math.radians(a)):.1f} '
    f'{256 + 240 * math.sin(math.radians(a)):.1f}) rotate(45)"/>'
    for a in (0, 90, 180, 270))


def write(name, text):
    with open(name, "w", encoding="utf-8") as f:
        f.write(text)


def png(svg_text, path, w=512, h=512, scale=1.0):
    render_svg(svg_text, path, w, h, scale=scale, transparent=True)


# ── ملفات المصدر (SVG) ─────────────────────────────────────
layers = {
    "sky": svg(SKY, defs=SKY_DEFS),
    "rays": svg(RAYS),
    "sun": svg(SUN_L, defs=SUN_DEFS),
    "land": svg(LAND, defs=LAND_DEFS),
    "ring": svg(RING),
}
for k, v in layers.items():
    write(f"{SRC_DIR}/layer-{k}.svg", v)

full = svg(SKY + RAYS_LOGO + SUN_L + LAND + RING, defs=SKY_DEFS + SUN_DEFS + LAND_DEFS)
# الأشعة والشمس يجب ألا تظهر تحت الأرض: الأرض تُرسم بعدهما فتغطيها
write(f"{LOGO_DIR}/zool-logo.svg", full)

# ── PNG للشعار ─────────────────────────────────────────────
for size in (512, 256, 128, 64, 48, 32):
    png(full, f"{LOGO_DIR}/zool-logo-{size}.png", 512, 512, scale=size / 512)

# ── طبقات Plymouth (كلها 512×512 بالإحداثيات نفسها) ──────────
png(layers["sky"], f"{PLY_DIR}/layer-sky.png")
png(layers["rays"], f"{PLY_DIR}/layer-rays.png")
png(layers["sun"], f"{PLY_DIR}/layer-sun.png")
png(layers["land"], f"{PLY_DIR}/layer-land.png")
png(layers["ring"], f"{PLY_DIR}/layer-ring.png")

# ── كلمة الشعار: ZOOL OS + زول ─────────────────────────────
z_d, z_w = text_path(OUTFIT, "ZOOL", 120, tracking=18)
o_d, o_w = text_path(OUTFIT, "OS", 120, tracking=18)
ar_d, ar_w = text_path(KUFI, "زول", 130)
W = 820
gap = 34
line1_w = z_w + gap + o_w
x1 = (W - line1_w) / 2
wm_inner = (
    f'<path d="{z_d}" transform="translate({x1:.1f} 128)" fill="{C["sand"]}"/>'
    f'<path d="{o_d}" transform="translate({x1 + z_w + gap:.1f} 128)" fill="{C["gold"]}"/>'
    f'<path d="{ar_d}" transform="translate({(W - ar_w) / 2:.1f} 272)" fill="{C["gold"]}"/>'
)
wordmark = svg(wm_inner, W, 300)
write(f"{SRC_DIR}/wordmark.svg", wordmark)
png(wordmark, f"{PLY_DIR}/wordmark.png", W, 300)
png(wordmark, f"{LOGO_DIR}/zool-wordmark.png", W, 300)

# ── تركيبة أفقية (شعار + اسم) ──────────────────────────────
lock = svg(
    f'<g transform="translate(20 20) scale(0.78)">{SKY + RAYS_LOGO + SUN_L + LAND + RING}</g>'
    f'<g transform="translate(450 70)">{wm_inner}</g>',
    1300, 440, defs=SKY_DEFS + SUN_DEFS + LAND_DEFS)
write(f"{LOGO_DIR}/zool-lockup.svg", lock)
png(lock, f"{LOGO_DIR}/zool-lockup.png", 1300, 440)

# ── نقاط التحميل ───────────────────────────────────────────
for name, col in (("dot-on", C["gold"]), ("dot-off", "#4a5a60")):
    png(svg(f'<circle cx="12" cy="12" r="9" fill="{col}"/>', 24, 24), f"{PLY_DIR}/{name}.png", 24, 24)

print("تم توليد الشعار وطبقاته:", LOGO_DIR, PLY_DIR)
