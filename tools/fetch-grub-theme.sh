#!/bin/bash
# ينزّل ثيم GRUB "YoRHa" (من OliveThePuffin) وقت البناء ويضعه في ملف التعريف.
# لا نضمّن الثيم في المستودع لأن مستودعه الأصلي لا يحمل ترخيصاً صريحاً.
# المصدر: https://github.com/OliveThePuffin/yorha-grub-theme
set -euo pipefail
cd "$(dirname "$0")/.."
DEST="profile/grub/themes/yorha"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [ -f "$DEST/theme.txt" ]; then
  echo "ثيم YoRHa موجود مسبقاً: $DEST"
  exit 0
fi

git clone --depth 1 https://github.com/OliveThePuffin/yorha-grub-theme "$TMP/yorha"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -r "$TMP/yorha/yorha-1920x1080/." "$DEST/"

# تخصيص النصوص لتحمل اسم النظام
sed -i 's/text = "L O A D I N G"/text = "Z O O L   O S"/; s/text = "- BOOTING SYSTEM . . ."/text = "- STARTING ZOOL . . ."/; s/text = "@KEYMAP_SHORT@"/text = "ENTER  boot      E  edit      C  command line"/' "$DEST/theme.txt"

cat > "$DEST/NOTICE.txt" <<'EON'
YoRHa GRUB theme — https://github.com/OliveThePuffin/yorha-grub-theme
Author: OliveThePuffin. Downloaded at build time; not part of the Zool OS repository.
Text labels in theme.txt were modified to show "ZOOL OS".
EON
echo "تم تنزيل ثيم YoRHa إلى $DEST"
