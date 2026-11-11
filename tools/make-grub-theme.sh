#!/bin/bash
# يجهّز ثيم GRUB الخاص بزول في iso/grub/themes/zool (يُستدعى من build-zoolos.sh)
#   المصدر: iso/grub/zool-theme/  (theme.txt + الصور)   ·   الخطوط تُحوَّل هنا إلى pf2 بـ grub-mkfont
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."

SRC="iso/grub/zool-theme"
DEST="iso/grub/themes/zool"
FONTS="share/fonts/zool"

rm -rf iso/grub/themes
mkdir -p "$DEST"
cp "$SRC"/theme.txt "$SRC"/*.png "$DEST"/

if command -v grub-mkfont >/dev/null 2>&1; then
  # اسم الخط داخل GRUB = "اسم العائلة + النمط + الحجم" (مثل: Amiri Bold 30)
  grub-mkfont -s 30 -o "$DEST/amiri_bold_30.pf2"    "$FONTS/Amiri-Latin-Bold.ttf"
  grub-mkfont -s 20 -o "$DEST/amiri_bold_20.pf2"    "$FONTS/Amiri-Latin-Bold.ttf"
  grub-mkfont -s 20 -o "$DEST/amiri_regular_20.pf2" "$FONTS/Amiri-Latin-Regular.ttf"
  grub-mkfont -s 14 -o "$DEST/amiri_regular_14.pf2" "$FONTS/Amiri-Latin-Regular.ttf"
  echo "✓ ثيم GRUB جاهز في $DEST (مع الخطوط)"
else
  echo "⚠ grub-mkfont غير موجود — سيظهر الثيم بخط GRUB الافتراضي" >&2
fi
