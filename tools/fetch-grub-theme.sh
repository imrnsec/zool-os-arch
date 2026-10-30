#!/bin/bash
# ينزّل ثيم GRUB "YoRHa" (من OliveThePuffin) وقت البناء ويضعه في ملف التعريف.
# لا نضمّن الثيم في المستودع لأن مستودعه الأصلي لا يحمل ترخيصاً صريحاً.
# المصدر: https://github.com/OliveThePuffin/yorha-grub-theme
set -euo pipefail
cd "$(dirname "$0")/.."
DEST="profile/grub/themes/yorha"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [ ! -f "$DEST/theme.txt" ]; then
  git clone --depth 1 https://github.com/OliveThePuffin/yorha-grub-theme "$TMP/yorha"
  rm -rf "$DEST"
  mkdir -p "$DEST"
  cp -r "$TMP/yorha/yorha-1920x1080/." "$DEST/"
fi

# تخصيص النصوص لتحمل اسم النظام (آمن عند التكرار)
sed -i 's/text = "L O A D I N G"/text = "Z O O L   O S"/; s/text = "- BOOTING SYSTEM . . ."/text = "- STARTING ZOOL . . ."/; s/text = "@KEYMAP_SHORT@"/text = "ENTER  boot      E  edit      C  command line"/' "$DEST/theme.txt"

# إزاحة النص الثاني حتى لا يتداخل مع العنوان
sed -zi 's/left = 18%\n\([[:space:]]*top = 70\)/left = 30%\n\1/' "$DEST/theme.txt"

# إضافة غطاء + شعار زول فوق علامة YoRHa المائية (مرة واحدة فقط)
if ! grep -q zool-cover.png "$DEST/theme.txt"; then
  cat > "$TMP/block.txt" <<'EOB'
+ image {
    left = 21%
    top = 28%
    width = 57%
    height = 41%
    file = "zool-cover.png"
}

+ image {
    left = 64.5%
    top = 33%
    file = "zool-logo.png"
}

+ image {
    left = 58.5%
    top = 55%
    width = 25%
    height = 9%
    file = "zool-wordmark.png"
}

EOB
  sed -i "0,/^+ boot_menu {/{/^+ boot_menu {/e cat $TMP/block.txt
}" "$DEST/theme.txt"
fi
cp profile/grub/zool-theme/cover.png "$DEST/zool-cover.png"
cp profile/grub/zool-theme/zool-logo.png profile/grub/zool-theme/zool-wordmark.png "$DEST/"

cat > "$DEST/NOTICE.txt" <<'EON'
YoRHa GRUB theme — https://github.com/OliveThePuffin/yorha-grub-theme
Author: OliveThePuffin. Downloaded at build time; not part of the Zool OS repository.
Text labels in theme.txt were modified to show "ZOOL OS".
EON
echo "تم تنزيل ثيم YoRHa إلى $DEST"
