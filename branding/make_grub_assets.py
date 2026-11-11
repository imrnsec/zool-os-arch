#!/usr/bin/env python3
"""يولّد ثيم GRUB الخاص بزول (خلفية + شريط التحديد) في iso/grub/zool-theme/.
الاستعمال:  python3 branding/make_grub_assets.py   (يحتاج Pillow و numpy)
الخطوط (pf2) تُولَّد وقت البناء بـ grub-mkfont — انظر tools/make-grub-theme.sh
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OUT = os.path.join(ROOT, "iso/grub/zool-theme")
LOGO = os.path.join(ROOT, "share/zool/logo")
os.makedirs(OUT, exist_ok=True)

W, H = 1920, 1080
NIGHT, SURFACE = (10, 16, 20), (23, 34, 41)
GOLD, TERRA, SAND = (232, 176, 74), (212, 106, 67), (243, 230, 204)

# ── سماء ليلية متدرجة مع وهج شمس خلف الشعار ──
yy, xx = np.mgrid[0:H, 0:W].astype(float)
t = (yy / H)[..., None]
sky = np.array(NIGHT) * (1 - t) + np.array(SURFACE) * t
cx, cy = W * 0.72, H * 0.46
glow = np.exp(-(((xx - cx) / 520) ** 2 + ((yy - cy) / 420) ** 2))[..., None]
sky = sky + glow * (np.array(TERRA) * 0.30 + np.array(GOLD) * 0.12)
rng = np.random.default_rng(3)
sky += rng.normal(0, 1.6, (H, W, 1))                       # ضجيج خفيف يمنع تدرّج الألوان المتقطع
img = Image.fromarray(np.clip(sky, 0, 255).astype(np.uint8), "RGB").convert("RGBA")

# ── نجوم خافتة ──
d = ImageDraw.Draw(img)
for _ in range(160):
    x, y = int(rng.uniform(0, W)), int(rng.uniform(0, H * 0.55))
    a = int(rng.uniform(40, 150))
    d.point((x, y), fill=(243, 230, 204, a))

# ── كثبان وأهرامات في الأسفل ──
land = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ld = ImageDraw.Draw(land)
def dune(base, amp, freq, phase, color):
    pts = [(0, H)] + [(x, base - amp * np.sin(x / freq + phase) - amp * 0.4 * np.sin(x / (freq * 0.37) + phase * 2))
                      for x in range(0, W + 8, 8)] + [(W, H)]
    ld.polygon(pts, fill=color)
for px, ph, pw in ((1660, 120, 96), (1770, 170, 130), (1870, 100, 84)):   # أهرامات مروي الحادة
    top = H - 190 - ph
    ld.polygon([(px - pw / 2, H - 170), (px, top), (px + pw / 2, H - 170)], fill=(18, 26, 31, 255))
    ld.polygon([(px, top), (px + pw / 2, H - 170), (px + pw * 0.12, H - 170)], fill=(13, 19, 23, 255))
dune(H - 150, 26, 310, 0.6, (16, 24, 28, 255))
dune(H - 90, 34, 420, 2.1, (12, 18, 22, 255))
dune(H - 30, 22, 260, 4.0, (8, 13, 16, 255))
img.alpha_composite(land)

# ── بطاقة القائمة (يسار) ──
card = Image.new("RGBA", (W, H), (0, 0, 0, 0))
cd = ImageDraw.Draw(card)
CX0, CY0, CX1, CY1 = 120, 330, 960, 900
cd.rounded_rectangle((CX0, CY0, CX1, CY1), 28, fill=(16, 24, 28, 205), outline=(232, 176, 74, 110), width=2)
cd.rounded_rectangle((CX0 + 40, CY0 + 34, CX0 + 46, CY0 + 74), 3, fill=GOLD + (255,))     # شرطة ذهبية بجانب العنوان
img.alpha_composite(card)

# ── الشعار والاسم (يمين) ──
logo = Image.open(f"{LOGO}/zool-logo-512.png").convert("RGBA").resize((400, 400), Image.LANCZOS)
shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ImageDraw.Draw(shadow).ellipse((1230, 215, 1650, 635), fill=(0, 0, 0, 130))
img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(26)))
img.alpha_composite(logo, (1240, 200))
wm = Image.open(f"{LOGO}/zool-wordmark.png").convert("RGBA")
wm = wm.resize((460, round(460 * wm.height / wm.width)), Image.LANCZOS)
img.alpha_composite(wm, (1440 - wm.width // 2, 630))
img.convert("RGB").save(f"{OUT}/background.png", optimize=True)

# ── شريط العنصر المحدد: 9 شرائح (نستعمل الوسط والطرفين فقط) ──
IH, R = 46, 14
def piece(w, box):
    im = Image.new("RGBA", (w, IH), (0, 0, 0, 0))
    full = Image.new("RGBA", (200, IH), (0, 0, 0, 0))
    fd = ImageDraw.Draw(full)
    fd.rectangle((0, 0, 200, IH), fill=GOLD + (255,))
    mask = Image.new("L", (200, IH), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, 199, IH - 1), R, fill=255)
    full.putalpha(mask)
    return full.crop(box)
piece(R, (0, 0, R, IH)).save(f"{OUT}/select_w.png")
piece(R, (200 - R, 0, 200, IH)).save(f"{OUT}/select_e.png")
c = Image.new("RGBA", (8, IH), (0, 0, 0, 0))
src = piece(200, (0, 0, 200, IH)).crop((96, 0, 104, IH))
src.save(f"{OUT}/select_c.png")
print("OK", OUT, "| card:", (CX0, CY0, CX1, CY1))
