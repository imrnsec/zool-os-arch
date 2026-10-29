#!/bin/bash
# يفحص كل الحزم في القائمة دفعة واحدة ويطبع المفقود منها (بدل اكتشافها واحدة واحدة أثناء البناء)
# التشغيل على Debian 13:  bash tools/check-packages.sh
# ملاحظة: حزم hypr* تأتي من backports؛ لتفحصها فعّل trixie-backports على جهازك أو تجاهلها.
cd "$(dirname "$0")/.."
sudo apt-get update -qq
missing=0
for p in $(grep -v '^[[:space:]]*#' config/package-lists/snln.list.chroot | grep -v '^[[:space:]]*$'); do
  apt-cache show "$p" >/dev/null 2>&1 || { echo "MISSING: $p"; missing=1; }
done
[ "$missing" = 0 ] && echo "كل الحزم موجودة ✔"
