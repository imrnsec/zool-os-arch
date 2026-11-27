#!/usr/bin/env python3
"""يولّد أصول GRUB لثيم Terminal الخاص بزول.
الاستعمال:  python3 branding/make_grub_assets.py   (يحتاج Pillow و numpy)

التصميم الجديد: خلفية شبه سوداء مع scanlines خفية — لا صور ولا زخارف.
شريط الاختيار: خط ذهبي رفيع على اليسار (بدل المستطيل الكامل).
"""
import os
import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OUT  = os.path.join(ROOT, "iso/grub/zool-theme")
os.makedirs(OUT, exist_ok=True)

W, H = 1920, 1080

# ── لوحة الألوان ──────────────────────────────────────────────────────────────
BG_DARK  = (6,  13,  9)   # #060d09  شبه أسود مع خضرة خافتة
BG_MID   = (8,  18, 12)   # طبقة وسطى
GOLD     = (232, 176, 74)  # #e8b04a

# ── الخلفية ───────────────────────────────────────────────────────────────────
# تدرّج عمودي خفيف من الأعلى (أدكن) إلى الأسفل (أضوأ قليلاً)
rng = np.random.default_rng(7)
yy  = np.arange(H, dtype=float)[:, None, None] / H                 # (H,1,1)
row = np.array(BG_DARK) * (1 - yy) + np.array(BG_MID) * yy       # (H,1,3)
bg  = np.broadcast_to(row, (H, W, 3)).copy().astype(float)

# ضجيج دقيق يمنع تقطّع تدرّج الألوان
bg += rng.normal(0, 0.9, (H, W, 3))

# scanlines أفقية خفية — تُعطي إحساس شاشة CRT دون مبالغة
for y in range(0, H, 3):
    bg[y] *= 0.88

img = Image.fromarray(np.clip(bg, 0, 255).astype(np.uint8), "RGB")

# نقطتا ضوء خضراوي فاتح (مثل phosphor glow) في الركن العلوي الأيسر والسفل الأيمن
gw = np.zeros((H, W), dtype=float)
cx1, cy1 = int(W * 0.07), int(H * 0.22)
cx2, cy2 = int(W * 0.80), int(H * 0.78)
xx, yy2  = np.meshgrid(np.arange(W), np.arange(H))
gw += 0.08 * np.exp(-(((xx - cx1) / 500) ** 2 + ((yy2 - cy1) / 400) ** 2))
gw += 0.05 * np.exp(-(((xx - cx2) / 600) ** 2 + ((yy2 - cy2) / 500) ** 2))
arr = np.array(img).astype(float)
arr[..., 1] = np.clip(arr[..., 1] + gw * 18, 0, 255)   # قناة Green فقط
img = Image.fromarray(arr.astype(np.uint8))

img.save(f"{OUT}/background.png", optimize=True)
print(f"✓ background.png → {OUT}/background.png")

# ── شريط الاختيار: select_*.png ───────────────────────────────────────────────
# تصميم: خط ذهبي رفيع على اليسار + طبقة شفافة خفيفة على الكل
# GRUB يستعمل 9-slice: select_w.png | select_c.png | select_e.png
IH = 46   # ارتفاع العنصر في القائمة

# الشريح الأيسر (W): خط ذهبي 3px + fade ذهبي
sw = Image.new("RGBA", (14, IH), (0, 0, 0, 0))
dw = ImageDraw.Draw(sw)
dw.rectangle((0, 0, 2, IH - 1), fill=GOLD + (220,))                 # خط 3px
dw.rectangle((3, 0, 13, IH - 1), fill=GOLD + (22,))                  # وهج خفيف
sw.save(f"{OUT}/select_w.png")

# الشريح الوسط (C): طبقة ذهبية شفافة جداً
sc = Image.new("RGBA", (8, IH), GOLD + (12,))
sc.save(f"{OUT}/select_c.png")

# الشريح الأيمن (E): شفاف
se = Image.new("RGBA", (4, IH), (0, 0, 0, 0))
se.save(f"{OUT}/select_e.png")

print(f"✓ select_{{w,c,e}}.png → {OUT}/")
print("OK — ثيم Terminal جاهز")
