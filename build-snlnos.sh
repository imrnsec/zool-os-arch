#!/bin/bash
# ═══════════════════════════════════════════════
#  سكربت بناء توزيعة snlnOS (Hyprland على Debian 13)
#  التشغيل:  bash build-snlnos.sh
#  يجب تشغيله داخل مجلد المشروع، على Debian 13 (جهاز أو VM أو حاوية privileged)
# ═══════════════════════════════════════════════
set -e
set -o pipefail
cd "$(dirname "$(readlink -f "$0")")"

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

echo "═══ [0/4] فحص المتطلبات ═══"
if [ -r /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" != "debian" ] || [ "${VERSION_ID%%.*}" != "13" ]; then
    echo "⚠ تحذير: نظام البناء الحالي ($PRETTY_NAME). الموصى به Debian 13 (trixie)."
    echo "  على Ubuntu أو Debian 12 قد يفشل debootstrap لـ trixie أو تختلف نسخة live-build."
    read -r -p "المتابعة رغم ذلك؟ [y/N] " ans
    [ "$ans" = "y" ] || [ "$ans" = "Y" ] || exit 1
  fi
fi
for cmd in lb debootstrap mksquashfs xorriso; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "✗ الأداة '$cmd' غير مثبتة. ثبّت المتطلبات:"
    echo "  sudo apt install live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools"
    exit 1
  }
done
free_gb=$(df -BG --output=avail . | tail -1 | tr -dc '0-9')
[ "${free_gb:-0}" -ge 20 ] || { echo "✗ المساحة الحرة ${free_gb}GB — يلزم 20GB على الأقل."; exit 1; }

echo "═══ [1/4] تنظيف بناء سابق ═══"
$SUDO lb clean || true

echo "═══ [2/4] إعداد الإعدادات (lb config ← auto/config) ═══"
lb config

echo "═══ [3/4] بناء النظام (قد يستغرق 30-90 دقيقة؛ السجل في build.log) ═══"
$SUDO lb build 2>&1 | tee build.log

echo "═══ [4/4] اكتمل البناء! ═══"
ISO="$(ls -1 snlnos-*.iso 2>/dev/null | head -1)"
if [ -z "$ISO" ]; then
  echo "✗ لم يُنتج ملف ISO — راجع آخر 40 سطراً من build.log"
  exit 1
fi
sha256sum "$ISO" | tee "$ISO.sha256"
echo ""
echo "ملف الـ ISO: $ISO"
echo ""
echo "اختبار في QEMU (UEFI) — يحتاج حزمة ovmf:"
echo "  qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 -cdrom $ISO \\"
echo "    -bios /usr/share/ovmf/OVMF.fd -device virtio-vga-gl -display gtk,gl=on"
echo "اختبار في QEMU (BIOS):"
echo "  qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 -cdrom $ISO \\"
echo "    -device virtio-vga-gl -display gtk,gl=on"
echo ""
echo "ملاحظة: Hyprland يحتاج تسريع رسوميات؛ استخدم virtio-vga-gl كما فوق (لا تستخدم -vga qxl)."
