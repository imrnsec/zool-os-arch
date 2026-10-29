#!/usr/bin/env python3
"""يولّد خلفيات سودانية (نيل، أهرامات مروي، هجليج، نخيل، فلوكة) بثلاث أجواء:
   nile-sunset (الافتراضية) · meroe-night · dune-dawn

الاستعمال:  python3 branding/make_wallpapers.py           (يحتاج playwright)
"""
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from zoolbrand import render_svg, HERE  # noqa: E402

ROOT = os.path.dirname(HERE)
OUT = os.path.join(ROOT, "profile/airootfs/usr/share/zool/wallpapers")
os.makedirs(OUT, exist_ok=True)
W, H = 2560, 1440


def f(v):
    return f"{v:.1f}"


def ridge(rng, y0, amp, color, opacity=1.0, seed_shift=0.0, step=16, extra=""):
    ph = [rng.uniform(0, 6.28) for _ in range(3)]
    pts = []
    for x in range(-step, W + 2 * step, step):
        t = x / W
        y = (y0 + amp * (0.55 * math.sin(t * 4.1 + ph[0] + seed_shift)
                         + 0.30 * math.sin(t * 9.3 + ph[1])
                         + 0.15 * math.sin(t * 17.0 + ph[2])))
        pts.append((x, y))
    d = "M" + " L".join(f"{f(x)} {f(y)}" for x, y in pts) + f" L{W + step} {H} L{-step} {H} Z"
    return f'<path d="{d}" fill="{color}" opacity="{opacity}" {extra}/>', pts


def ridge_y(pts, x):
    for (x1, y1), (x2, y2) in zip(pts, pts[1:]):
        if x1 <= x <= x2:
            return y1 + (y2 - y1) * (x - x1) / (x2 - x1)
    return pts[-1][1]


def pyramid(cx, base, w, h, dark, light, course="#000000", co=0.18):
    hw = w / 2
    lines = "".join(
        f'<line x1="{f(cx - hw * (1 - k / 8))}" y1="{f(base - k * h / 8)}" x2="{f(cx + hw * (1 - k / 8))}" '
        f'y2="{f(base - k * h / 8)}" stroke="{course}" stroke-opacity="{co}" stroke-width="{max(1.0, w / 90):.1f}"/>'
        for k in range(1, 8))
    return (f'<polygon points="{f(cx - hw)},{f(base + 6)} {f(cx)},{f(base - h)} {f(cx)},{f(base + 6)}" fill="{dark}"/>'
            f'<polygon points="{f(cx)},{f(base - h)} {f(cx + hw)},{f(base + 6)} {f(cx)},{f(base + 6)}" fill="{light}"/>' + lines)


def acacia(x, y, s, col):
    """شجرة هجليج: جذع منحنٍ وتاج مسطّح على شكل مظلة."""
    trunk = (f'<path d="M{f(x)} {f(y)} C{f(x - 10 * s)} {f(y - 90 * s)} {f(x + 22 * s)} {f(y - 150 * s)} {f(x + 4 * s)} {f(y - 215 * s)}" '
             f'fill="none" stroke="{col}" stroke-width="{f(15 * s)}" stroke-linecap="round"/>'
             f'<path d="M{f(x + 6 * s)} {f(y - 170 * s)} C{f(x + 60 * s)} {f(y - 195 * s)} {f(x + 120 * s)} {f(y - 220 * s)} {f(x + 170 * s)} {f(y - 232 * s)}" '
             f'fill="none" stroke="{col}" stroke-width="{f(8 * s)}" stroke-linecap="round"/>'
             f'<path d="M{f(x)} {f(y - 140 * s)} C{f(x - 60 * s)} {f(y - 180 * s)} {f(x - 120 * s)} {f(y - 205 * s)} {f(x - 175 * s)} {f(y - 214 * s)}" '
             f'fill="none" stroke="{col}" stroke-width="{f(8 * s)}" stroke-linecap="round"/>')
    blobs = [(-175, -216, 105, 25), (-95, -240, 120, 32), (0, -250, 140, 36), (105, -246, 125, 32),
             (178, -236, 105, 27), (232, -222, 70, 20), (-235, -204, 66, 18)]
    canopy = "".join(f'<ellipse cx="{f(x + bx * s)}" cy="{f(y + by * s)}" rx="{f(rx * s)}" ry="{f(ry * s)}" fill="{col}"/>'
                     for bx, by, rx, ry in blobs)
    return f'<g>{trunk}{canopy}</g>'


def palm(x, y, s, col, lean=1):
    top = (x + 70 * s * lean, y - 330 * s)
    trunk = (f'<path d="M{f(x)} {f(y)} Q{f(x + 10 * s * lean)} {f(y - 190 * s)} {f(top[0])} {f(top[1])}" '
             f'fill="none" stroke="{col}" stroke-width="{f(17 * s)}" stroke-linecap="round"/>')
    fronds = []
    for ang in (-170, -145, -118, -92, -66, -40, -14, 12, 160):
        a = math.radians(ang)
        L = 150 * s
        ex = top[0] + L * math.cos(a)
        ey = top[1] + L * math.sin(a) + 60 * s     # تتدلى الأوراق نحو الأسفل
        cx_ = top[0] + L * 0.55 * math.cos(a)
        cy_ = top[1] + L * 0.55 * math.sin(a) - 38 * s
        w = 9 * s
        fronds.append(f'<path d="M{f(top[0])} {f(top[1])} Q{f(cx_)} {f(cy_ - w)} {f(ex)} {f(ey)} Q{f(cx_)} {f(cy_ + w)} {f(top[0])} {f(top[1])} Z" fill="{col}"/>')
    return trunk + "".join(fronds)


def reeds(rng, x0, x1, y, hmin, hmax, col, n):
    out = []
    for _ in range(n):
        x = rng.uniform(x0, x1)
        h = rng.uniform(hmin, hmax)
        dx = rng.uniform(-40, 40)
        out.append(f'<path d="M{f(x)} {f(y)} Q{f(x + dx * 0.3)} {f(y - h * 0.6)} {f(x + dx)} {f(y - h)}" fill="none" '
                   f'stroke="{col}" stroke-width="{rng.uniform(2.5, 5):.1f}" stroke-linecap="round"/>')
    return "".join(out)


def felucca(x, y, s, hull, sail, sail_shade, refl):
    """فلوكة نيلية: شراع لاتيني مثلثي كبير على سارية مائلة."""
    body = (f'<path d="M-100 0 Q0 30 125 -14 L108 -26 Q0 -14 -86 -28 Z" fill="{hull}"/>'
            f'<line x1="-118" y1="-30" x2="70" y2="-250" stroke="{hull}" stroke-width="5" stroke-linecap="round"/>'
            f'<polygon points="-114,-34 66,-244 40,-34" fill="{sail}"/>'
            f'<polygon points="66,-244 40,-34 -20,-34" fill="{sail_shade}" opacity="0.5"/>'
            f'<line x1="40" y1="-30" x2="40" y2="-60" stroke="{hull}" stroke-width="3"/>')
    boat = f'<g transform="translate({f(x)} {f(y)}) scale({s})">{body}</g>'
    mirror = f'<g transform="translate({f(x)} {f(y + 6 * s)}) scale({s} {-0.45 * s})" opacity="{refl}">{body}</g>'
    return mirror + boat


def birds(rng, x0, y0, n, col):
    out = []
    for _ in range(n):
        x = x0 + rng.uniform(0, 520)
        y = y0 + rng.uniform(-60, 80)
        sz = rng.uniform(10, 22)
        out.append(f'<path d="M{f(x - sz)} {f(y)} Q{f(x - sz / 2)} {f(y - sz * 0.7)} {f(x)} {f(y)} Q{f(x + sz / 2)} {f(y - sz * 0.7)} {f(x + sz)} {f(y)}" '
                   f'fill="none" stroke="{col}" stroke-width="2.6" stroke-linecap="round"/>')
    return "".join(out)


THEMES = {
    "nile-sunset": dict(
        sky=[(0, "#262c52"), (0.30, "#5d4768"), (0.52, "#c9715b"), (0.66, "#f0a85a"), (0.78, "#f8d68f")],
        sun=(0.36, 0.585, 125, "#ffe3a0", "#ffb457"), moon=False, stars=0,
        haze="#f4b872", ridge_far="#8a5a6a", ridge_mid="#6d4558", pyr=("#5a3445", "#a8615a"),
        sil="#1b1316", sil_far="#3a2630", river_top="#f6b768", river_bot="#2b4a63", glint="#ffe6b0",
        sail="#f8e3b8", sail_shade="#d29a6a", cloud="#f6a46a", glow="#ffcf7a"),
    "meroe-night": dict(
        sky=[(0, "#070d1a"), (0.35, "#12213a"), (0.6, "#2a3a56"), (0.76, "#6a6a80")],
        sun=(0.70, 0.22, 66, "#fff6dd", "#e9dcb8"), moon=True, stars=240,
        haze="#7a86a0", ridge_far="#27364f", ridge_mid="#1b2a40", pyr=("#16243a", "#4a5f7e"),
        sil="#070b10", sil_far="#101a28", river_top="#7f8fae", river_bot="#0c1e2c", glint="#e8efff",
        sail="#cfd8ea", sail_shade="#7e8db0", cloud="#3a4c6b", glow="#cfd9f0"),
    "dune-dawn": dict(
        sky=[(0, "#34456b"), (0.28, "#8a76a0"), (0.50, "#e0a0a0"), (0.64, "#f7c48f"), (0.78, "#fde6b4")],
        sun=(0.64, 0.60, 105, "#fff6de", "#ffd9a2"), moon=False, stars=18,
        haze="#fbd9a8", ridge_far="#c18c98", ridge_mid="#a46e7c", pyr=("#80525e", "#cf8a74"),
        sil="#2c2128", sil_far="#6a4a58", river_top="#f9cf99", river_bot="#5d6f8c", glint="#fff2d4",
        sail="#fff0d2", sail_shade="#e0b088", cloud="#ffd9b0", glow="#ffe0a8"),
}


def build(name, T):
    rng = random.Random(hash(name) & 0xFFFF)
    rng = random.Random(sum(map(ord, name)))
    sx, sy, sr, sc1, sc2 = T["sun"]
    sx, sy = sx * W, sy * H
    horizon = 0.655 * H
    parts = []
    defs = []

    stops = "".join(f'<stop offset="{o}" stop-color="{c}"/>' for o, c in T["sky"])
    defs.append(f'<linearGradient id="sky" x1="0" y1="0" x2="0" y2="{0.78}">{stops}</linearGradient>')
    defs.append(f'<radialGradient id="sunc" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="{sc1}"/>'
                f'<stop offset="0.85" stop-color="{sc2}"/><stop offset="1" stop-color="{sc2}"/></radialGradient>')
    defs.append(f'<radialGradient id="glow" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="{T["glow"]}" stop-opacity="0.75"/>'
                f'<stop offset="0.4" stop-color="{T["glow"]}" stop-opacity="0.25"/><stop offset="1" stop-color="{T["glow"]}" stop-opacity="0"/></radialGradient>')
    defs.append(f'<linearGradient id="river" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{T["river_top"]}"/>'
                f'<stop offset="1" stop-color="{T["river_bot"]}"/></linearGradient>')
    defs.append('<filter id="blur"><feGaussianBlur stdDeviation="22"/></filter>')
    defs.append('<filter id="blur2"><feGaussianBlur stdDeviation="3"/></filter>')
    defs.append('<radialGradient id="vig" cx="0.5" cy="0.5" r="0.75"><stop offset="0.55" stop-color="#000" stop-opacity="0"/>'
                '<stop offset="1" stop-color="#000" stop-opacity="0.45"/></radialGradient>')

    parts.append(f'<rect width="{W}" height="{H}" fill="url(#sky)"/>')

    for _ in range(T["stars"]):
        x, y = rng.uniform(0, W), rng.uniform(0, 0.52 * H)
        parts.append(f'<circle cx="{f(x)}" cy="{f(y)}" r="{rng.uniform(0.8, 2.4):.1f}" fill="#fff" opacity="{rng.uniform(0.35, 0.95):.2f}"/>')

    parts.append(f'<circle cx="{f(sx)}" cy="{f(sy)}" r="{f(sr * 4.2)}" fill="url(#glow)"/>')
    if not T["moon"]:
        parts.append(f'<circle cx="{f(sx)}" cy="{f(sy)}" r="{sr}" fill="url(#sunc)"/>')
    if T["moon"]:      # هلال حقيقي بقناع (بدون قرص يغطّي السماء)
        parts.append('<mask id="crescent"><rect width="%d" height="%d" fill="black"/>'
                     '<circle cx="%s" cy="%s" r="%s" fill="white"/>'
                     '<circle cx="%s" cy="%s" r="%s" fill="black"/></mask>'
                     % (W, H, f(sx), f(sy), f(sr), f(sx + sr * 0.42), f(sy - sr * 0.1), f(sr * 0.86)))
        parts.append(f'<rect width="{W}" height="{H}" fill="#fff6dd" mask="url(#crescent)"/>')

    for i in range(7):  # غيوم ناعمة ممدودة
        cx_, cy_ = rng.uniform(0.05, 0.95) * W, rng.uniform(0.12, 0.5) * H
        parts.append(f'<ellipse cx="{f(cx_)}" cy="{f(cy_)}" rx="{rng.uniform(220, 480):.0f}" ry="{rng.uniform(14, 34):.0f}" '
                     f'fill="{T["cloud"]}" opacity="{rng.uniform(0.22, 0.45):.2f}" filter="url(#blur)"/>')

    far, far_pts = ridge(rng, horizon - 40, 38, T["ridge_far"], 0.85)
    parts.append(far)
    parts.append(f'<rect x="0" y="{f(horizon - 120)}" width="{W}" height="140" fill="{T["haze"]}" opacity="0.28" filter="url(#blur)"/>')
    mid, mid_pts = ridge(rng, horizon - 8, 26, T["ridge_mid"], 1.0)
    parts.append(mid)

    # أهرامات مروي على التلة الوسطى (أبعد = أصغر وأبهت)
    pyr_pos = [(0.70, 0.55), (0.755, 0.9), (0.80, 0.7), (0.855, 1.1), (0.91, 0.62), (0.965, 0.8)]
    for t, k in pyr_pos:
        x = t * W
        base = ridge_y(mid_pts, x) + 4
        w = 120 * k
        parts.append(pyramid(x, base, w, w * 1.35, T["pyr"][0], T["pyr"][1]))
    parts.append(f'<rect x="0" y="{f(horizon - 30)}" width="{W}" height="70" fill="{T["haze"]}" opacity="0.18" filter="url(#blur)"/>')

    # النهر: شريط يتسع نحو الأسفل
    left_bank = [(0, horizon + 70), (0.18 * W, horizon + 20), (0.42 * W, horizon + 4), (0.62 * W, horizon + 4)]
    river = (f'<path d="M0 {f(horizon + 4)} L{W} {f(horizon + 4)} L{W} {H} L0 {H} Z" fill="url(#river)"/>')
    parts.append(river)
    for i in range(70):  # بريق الشمس على الماء
        t = i / 70
        y = horizon + 14 + t ** 1.5 * (H - horizon - 14) * 0.78
        wd = (30 + 380 * t ** 1.2) * rng.uniform(0.5, 1.0)
        x = sx + rng.uniform(-1, 1) * (30 + 220 * t)
        parts.append(f'<rect x="{f(x - wd / 2)}" y="{f(y)}" width="{f(wd)}" height="{f(2 + 6 * t)}" rx="3" '
                     f'fill="{T["glint"]}" opacity="{(0.75 - 0.5 * t) * rng.uniform(0.5, 1):.2f}"/>')
    parts.append(f'<rect x="0" y="{f(horizon)}" width="{W}" height="26" fill="{T["haze"]}" opacity="0.3" filter="url(#blur2)"/>')

    # فلوكة نيلية
    parts.append(felucca(0.52 * W, 0.76 * H, 1.45, T["sil"], T["sail"], T["sail_shade"], 0.22))
    parts.append(felucca(0.60 * W, 0.70 * H, 0.62, T["sil_far"], T["sail"], T["sail_shade"], 0.18))

    parts.append(birds(rng, 0.52 * W, 0.2 * H, 7, T["sil"] if not T["moon"] else "#cfd9f0"))

    # الضفة اليمنى: هجليج
    bank_r = ridge(rng, 0.93 * H, 22, T["sil"], 1.0, seed_shift=2.0)[0]
    parts.append(f'<g opacity="0.55">{acacia(0.84 * W, 0.86 * H, 0.55, T["sil_far"])}</g>')
    parts.append(acacia(0.90 * W, 0.97 * H, 1.35, T["sil"]))
    parts.append(acacia(0.755 * W, 0.915 * H, 0.7, T["sil"]))
    # الضفة اليسرى: نخيل وقصب
    parts.append(f'<g opacity="0.6">{palm(0.12 * W, 0.80 * H, 0.45, T["sil_far"], 1)}</g>')
    parts.append(palm(0.065 * W, 0.99 * H, 1.15, T["sil"], 1))
    parts.append(palm(0.155 * W, 0.97 * H, 0.9, T["sil"], -1))
    ground = ridge(rng, 0.955 * H, 14, T["sil"], 1.0, seed_shift=1.0)[0]
    parts.append(ground)
    parts.append(reeds(rng, 0, 0.30 * W, H * 0.985, 90, 260, T["sil"], 150))
    parts.append(reeds(rng, 0.62 * W, W, H * 0.99, 80, 230, T["sil"], 170))

    parts.append(f'<rect width="{W}" height="{H}" fill="url(#vig)"/>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">'
            f'<defs>{"".join(defs)}</defs>{"".join(parts)}</svg>')


if __name__ == "__main__":
    only = sys.argv[1:] or list(THEMES)
    for name in only:
        svg_text = build(name, THEMES[name])
        with open(os.path.join(HERE, "src", f"wallpaper-{name}.svg"), "w", encoding="utf-8") as fh:
            fh.write(svg_text)
        render_svg(svg_text, os.path.join(OUT, f"{name}.jpg"), W, H, scale=1.0, transparent=False, quality=90)
        print("OK", name)
