#!/usr/bin/env python3
"""يولّد أصول زول لثيم GRUB: غطاء يخفي شعار YoRHa الأصلي + شعار زول + الاسم.
الاستعمال:  python3 branding/make_grub_assets.py   (يحتاج Pillow و numpy)
"""
import os
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OUT = os.path.join(ROOT, "profile/grub/zool-theme")
LOGO = os.path.join(ROOT, "profile/airootfs/usr/share/zool/logo")
os.makedirs(OUT, exist_ok=True)

# غطاء بلون خلفية YoRHa (≈ 20,16,14) مع ضجيج خفيف وحواف ناعمة حتى لا يظهر كمستطيل
W, H, FEATHER = 1100, 440, 110
rng = np.random.default_rng(7)
base = np.array([20, 16, 14], dtype=float)
noise = rng.normal(0, 5.5, (H, W, 1))
rgb = np.clip(base.reshape(1, 1, 3) + noise, 0, 255)
yy, xx = np.mgrid[0:H, 0:W]
edge = np.minimum.reduce([xx, W - 1 - xx, yy, H - 1 - yy]).astype(float)
t = np.clip(edge / FEATHER, 0, 1)
alpha = (t * t * (3 - 2 * t) * 255)
img = np.dstack([rgb, alpha[..., None]]).astype(np.uint8)
Image.fromarray(img, "RGBA").save(f"{OUT}/cover.png")

Image.open(f"{LOGO}/zool-logo-256.png").convert("RGBA").save(f"{OUT}/zool-logo.png")
Image.open(f"{LOGO}/zool-wordmark.png").convert("RGBA").save(f"{OUT}/zool-wordmark.png")
print("OK", OUT)
