#!/usr/bin/env python3
"""خلفيات الثيمات:
  1) لوحة «كثبان مروي» مرسومة بألوان كل ثيم (حادة على أي شاشة) → themes/<id>/backgrounds/1-meroe-dunes.jpg
  2) صور فوتوغرافية (branding/photos/) تُركَّب على لوحة 16:9 كاملة دون قص:
     الصورة كلها ظاهرة في الوسط وخلفها نسخة ضبابية منها تملأ الفراغ.
الاستعمال:  python3 branding/make_theme_backgrounds.py     (يحتاج Pillow و numpy)
"""
import os, re, glob
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageOps, ImageEnhance

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W, H, SS = 1920, 1080, 2          # SS: رسم بضعف الدقة ثم تصغير = حواف ناعمة

def toml(path):
    d = {}
    for line in open(path, encoding="utf-8"):
        m = re.match(r'\s*([a-z_]+)\s*=\s*"(#[0-9a-fA-F]{6})"', line)
        if m: d[m.group(1)] = tuple(int(m.group(2)[i:i + 2], 16) for i in (1, 3, 5))
    return d

def mix(a, b, t): return tuple(a[i] * (1 - t) + b[i] * t for i in range(3))
def rgb(c): return tuple(int(max(0, min(255, round(v)))) for v in c)

def dunes(c, out):
    bg = c["background"]; dark = c.get("darker_background", c.get("dark_background", bg))
    acc = c["accent"]; warm = c.get("orange", c.get("yellow", acc)); water = c.get("cyan", c.get("blue", acc))
    fg = c["foreground"]
    w, h = W * SS, H * SS
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    t = np.clip(yy / (h * 0.72), 0, 1)[..., None] ** 1.4
    sky = np.array(dark, np.float32) * (1 - t) + np.array(mix(bg, warm, 0.38), np.float32) * t
    sx, sy = w * 0.66, h * 0.60
    r2 = ((xx - sx) / (w * 0.30)) ** 2 + ((yy - sy) / (h * 0.42)) ** 2
    sky += np.exp(-r2)[..., None] * np.array(mix(warm, acc, 0.4), np.float32) * 0.42
    sky += np.random.default_rng(7).normal(0, 1.4, (h, w, 1)).astype(np.float32)
    img = Image.fromarray(np.clip(sky, 0, 255).astype(np.uint8), "RGB").convert("RGBA")
    d = ImageDraw.Draw(img)
    rng = np.random.default_rng(11)
    for _ in range(260):                                   # نجوم
        x, y = rng.uniform(0, w), rng.uniform(0, h * 0.5)
        r = rng.uniform(0.6, 1.8) * SS / 2; a = int(rng.uniform(50, 190) * (1 - y / (h * 0.5)))
        d.ellipse((x - r, y - r, x + r, y + r), fill=rgb(fg) + (a,))
    # الشمس
    R = h * 0.115
    halo = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(halo).ellipse((sx - R * 1.9, sy - R * 1.9, sx + R * 1.9, sy + R * 1.9), fill=rgb(mix(warm, acc, 0.5)) + (70,))
    img.alpha_composite(halo.filter(ImageFilter.GaussianBlur(R * 0.55)))
    d = ImageDraw.Draw(img)
    d.ellipse((sx - R, sy - R, sx + R, sy + R), fill=rgb(mix(acc, (255, 255, 255), 0.18)) + (255,))
    # الأهرامات (حادة الزوايا كأهرامات مروي): وجه مضيء ووجه ظل
    base = h * 0.70
    lit, shade = rgb(mix(bg, warm, 0.30)), rgb(mix(dark, (0, 0, 0), 0.25))
    for px, ph, pw in ((0.47, 0.30, 0.150), (0.585, 0.40, 0.200), (0.725, 0.27, 0.135), (0.83, 0.19, 0.095)):
        x, top, half = w * px, base - h * ph, w * pw / 2
        d.polygon([(x - half, base), (x, top), (x + half * 0.18, base)], fill=shade + (255,))
        d.polygon([(x, top), (x + half, base), (x + half * 0.18, base)], fill=lit + (255,))
    # الكثبان
    def dune(y0, amp, freq, ph, col):
        pts = [(0, h)] + [(x, y0 - amp * np.sin(x / freq + ph) - amp * 0.45 * np.sin(x / (freq * 0.41) + ph * 1.7))
                          for x in range(0, w + 16, 16)] + [(w, h)]
        d.polygon(pts, fill=rgb(col) + (255,))
    dune(h * 0.71, h * 0.020, w * 0.16, 0.4, mix(bg, warm, 0.20))
    dune(h * 0.78, h * 0.028, w * 0.21, 2.0, mix(bg, warm, 0.10))
    # النيل: شريط منحنٍ بين الكثبان
    pts_top, pts_bot = [], []
    for i in range(0, 101):
        k = i / 100
        x = w * (-0.05 + 1.1 * k)
        yc = h * (0.865 + 0.035 * np.sin(k * 5.2 + 0.6))
        th = h * (0.018 + 0.030 * k)
        pts_top.append((x, yc - th)); pts_bot.append((x, yc + th))
    d.polygon(pts_top + pts_bot[::-1], fill=rgb(mix(bg, water, 0.62)) + (255,))
    hi = [(x, y + (b[1] - y) * 0.28) for (x, y), b in zip(pts_top, pts_bot)]
    d.line(hi, fill=rgb(mix(water, (255, 255, 255), 0.35)) + (150,), width=max(2, SS * 2))
    dune(h * 0.955, h * 0.030, w * 0.19, 3.6, mix(dark, bg, 0.55))
    dune(h * 1.01, h * 0.022, w * 0.13, 5.1, dark)
    img.convert("RGB").resize((W, H), Image.LANCZOS).save(out, quality=92, optimize=True, subsampling=0)

def photo(src, out):
    """الصورة كاملة بلا قص على لوحة 16:9، مع توضيح خفيف."""
    im = ImageOps.exif_transpose(Image.open(src)).convert("RGB")
    k = min(W / im.width, H / im.height)
    fit = im.resize((round(im.width * k), round(im.height * k)), Image.LANCZOS)
    if k > 1.05:                                            # صورة صغيرة كُبّرت: نظّف ثم وضّح
        fit = fit.filter(ImageFilter.MedianFilter(3))
    fit = fit.filter(ImageFilter.UnsharpMask(radius=2.2, percent=70, threshold=3))
    fit = ImageEnhance.Contrast(fit).enhance(1.05)
    back = ImageOps.fit(im, (W, H), Image.LANCZOS).filter(ImageFilter.GaussianBlur(42))
    back = ImageEnhance.Brightness(back).enhance(0.55)
    x, y = (W - fit.width) // 2, (H - fit.height) // 2
    if fit.width < W - 4 or fit.height < H - 4:             # ظل ناعم يفصل الصورة عن خلفيتها
        sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(sh).rectangle((x - 6, y - 6, x + fit.width + 6, y + fit.height + 6), fill=(0, 0, 0, 150))
        back = Image.alpha_composite(back.convert("RGBA"), sh.filter(ImageFilter.GaussianBlur(24))).convert("RGB")
    back.paste(fit, (x, y))
    back.save(out, quality=90, optimize=True)
    return im.size, fit.size

# أي صورة تذهب لأي ثيم
PHOTOS = {
    "khartoum-golden.jpg":  ["zool"],
    "nile-dusk.jpg":        ["blue-bubble", "tokyo-night", "catppuccin"],
    "khartoum-mono.jpg":    ["deep-one", "matte-black", "nord"],
    "evening-sky.jpg":      ["circuit-horizon", "kanagawa", "ristretto"],
    "river-sunset.jpg":     ["dionysus", "gruvbox", "everforest", "zool"],
}

if __name__ == "__main__":
    for tdir in sorted(glob.glob(f"{ROOT}/themes/*/")):
        tid = os.path.basename(tdir.rstrip("/"))
        os.makedirs(tdir + "backgrounds", exist_ok=True)
        if tid != "zool":                                   # لثيم زول لوحاته المرسومة الخاصة
            dunes(toml(tdir + "colors.toml"), tdir + "backgrounds/1-meroe-dunes.jpg")
        for old in glob.glob(tdir + "backgrounds/photo-*.jpg") + [tdir + "backgrounds/" + n for n in PHOTOS]:
            if os.path.exists(old): os.remove(old)
    for name, themes in PHOTOS.items():
        src = f"{ROOT}/branding/photos/{name}"
        for tid in themes:
            print(name, "→", tid, photo(src, f"{ROOT}/themes/{tid}/backgrounds/photo-{name}"))
