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

mkfonts() {
  # اسم الخط داخل GRUB = "اسم العائلة + النمط + الحجم" (مثل: Amiri Bold 30) — نستعمل Amiri اللاتيني لأن GRUB لا يشكّل الحروف العربية
  grub-mkfont -s 30 -o "$DEST/amiri_bold_30.pf2"    "$FONTS/Amiri-Latin-Bold.ttf" &&
  grub-mkfont -s 20 -o "$DEST/amiri_bold_20.pf2"    "$FONTS/Amiri-Latin-Bold.ttf" &&
  grub-mkfont -s 20 -o "$DEST/amiri_regular_20.pf2" "$FONTS/Amiri-Latin-Regular.ttf" &&
  grub-mkfont -s 14 -o "$DEST/amiri_regular_14.pf2" "$FONTS/Amiri-Latin-Regular.ttf"
}

# grub-mkfont يحتاج مكتبة freetype2 (اعتماد اختياري لحزمة grub) — نثبّتها إن غابت ونحن root على Arch
if ! mkfonts 2>/dev/null; then
  if [ "$(id -u)" = 0 ] && command -v pacman >/dev/null 2>&1; then
    echo "  تثبيت freetype2 (يلزم grub-mkfont)…"
    pacman -S --needed --noconfirm freetype2 >/dev/null
  fi
  rm -f "$DEST"/*.pf2
  if ! mkfonts; then
    rm -f "$DEST"/*.pf2
    echo "⚠ تعذر توليد خطوط GRUB (ثبّت freetype2) — سيظهر الثيم بخط GRUB الافتراضي" >&2
    exit 0
  fi
fi
echo "✓ ثيم GRUB جاهز في $DEST (مع الخطوط)"
