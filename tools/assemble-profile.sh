#!/bin/bash
# ═══════════════════════════════════════════════
#  يجمّع ملفات النظام من المجلد الرئيسي في ملف تعريف archiso جاهز للبناء.
#  (كما يفعل Omarchy: الملفات في جذر المستودع بنفس بنية النظام المثبّت)
#
#    bin/          →  /usr/local/bin          أوامر زول (zool-*)
#    config/       →  /etc/skel/.config       إعدادات المستخدم (Hyprland، Waybar…)
#    etc/          →  /etc                    إعدادات النظام (SDDM، systemd، …)
#    share/        →  /usr/share              الثيمات والخطوط والشعارات والخلفيات
#    local-share/  →  /usr/local/share        ملفات مساندة
#    root/         →  /root                   (اختياري)
#    iso/          →  جذر ملف التعريف         packages.x86_64 · pacman.conf · profiledef.sh · grub/ · syslinux/
#
#  الاستخدام:  bash tools/assemble-profile.sh [المجلد-الهدف]   (الافتراضي: build/profile)
# ═══════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."

DEST="${1:-build/profile}"
rm -rf "$DEST"
mkdir -p "$DEST/airootfs/etc/skel" "$DEST/airootfs/usr/local"

# -a يحفظ الروابط الرمزية والصلاحيات (مهم لـ systemd *.wants)
cp -a iso/. "$DEST/"
cp -a etc/. "$DEST/airootfs/etc/"
cp -a config "$DEST/airootfs/etc/skel/.config"
cp -a share "$DEST/airootfs/usr/share"
cp -a bin "$DEST/airootfs/usr/local/bin"
[ -d local-share ] && cp -a local-share "$DEST/airootfs/usr/local/share"
[ -d root ]        && cp -a root "$DEST/airootfs/root"

# نسخة زول (لأمر zool-update) + اعتبار الترحيلات الحالية منفَّذة على هذا الـ ISO
mkdir -p "$DEST/airootfs/var/lib/zool/migrations"
git -c safe.directory='*' rev-parse HEAD > "$DEST/airootfs/var/lib/zool/version" 2>/dev/null || echo unknown > "$DEST/airootfs/var/lib/zool/version"
for m in migrations/*.sh; do [ -f "$m" ] && touch "$DEST/airootfs/var/lib/zool/migrations/$(basename "$m")"; done

# لا ننقل ملفات بايثون المؤقتة إلى النظام
find "$DEST" -name __pycache__ -type d -prune -exec rm -rf {} +

echo "✓ جُمّع ملف التعريف في: $DEST"
