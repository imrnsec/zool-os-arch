#!/bin/bash
# ═══════════════════════════════════════════════
#  سكربت بناء Zool OS (زول) — Arch + Hyprland
#  التشغيل:  bash build-zoolos.sh
#  يجب تشغيله على Arch Linux (جهاز أو VM أو حاوية archlinux --privileged)
# ═══════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"
WORK="${ZOOL_WORK:-/var/tmp/zoolos-work}"
OUT="${ZOOL_OUT:-$PWD/out}"

echo "═══ [0/4] فحص المتطلبات ═══"
if [ ! -f /etc/arch-release ]; then
  echo "✗ هذا السكربت يعمل على Arch Linux فقط (أو حاوية archlinux)."
  echo "  على غير Arch: docker run --privileged -v \"\$PWD\":/zool -w /zool archlinux bash -c 'pacman -Sy --noconfirm archiso git && bash build-zoolos.sh'"
  exit 1
fi
for cmd in mkarchiso git grub-mkstandalone mksquashfs xorriso mformat; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "✗ الأداة '$cmd' غير مثبتة. ثبّت المتطلبات:"
    echo "  sudo pacman -S --needed archiso git grub squashfs-tools libisoburn mtools dosfstools qemu-desktop edk2-ovmf"
    exit 1
  }
done
free_gb=$(df -BG --output=avail "$(dirname "$WORK")" | tail -1 | tr -dc '0-9')
[ "${free_gb:-0}" -ge 20 ] || { echo "✗ المساحة الحرة ${free_gb}GB في $(dirname "$WORK") — يلزم 20GB على الأقل."; exit 1; }

echo "═══ [1/4] تنزيل ثيم GRUB (YoRHa) ═══"
bash tools/fetch-grub-theme.sh

echo "═══ [2/4] تنظيف بناء سابق ═══"
$SUDO rm -rf "$WORK"
mkdir -p "$OUT"

echo "═══ [3/4] بناء الـ ISO (قد يستغرق 15-40 دقيقة؛ السجل في build.log) ═══"
$SUDO mkarchiso -v -w "$WORK" -o "$OUT" profile 2>&1 | tee build.log

echo "═══ [4/4] اكتمل البناء! ═══"
ISO="$(ls -1t "$OUT"/zoolos-*.iso 2>/dev/null | head -1)"
if [ -z "$ISO" ]; then
  echo "✗ لم يُنتج ملف ISO — راجع آخر 40 سطراً من build.log"
  exit 1
fi
( cd "$OUT" && sha256sum "$(basename "$ISO")" | tee "$(basename "$ISO").sha256" )
echo ""
echo "ملف الـ ISO: $ISO"
echo ""
echo "اختبار في QEMU (UEFI + تسريع رسوميات — Hyprland يحتاجه):"
echo "  qemu-system-x86_64 -enable-kvm -cpu host -m 4096 -smp 2 -cdrom $ISO \\"
echo "    -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \\"
echo "    -device virtio-vga-gl -display gtk,gl=on"
echo ""
echo "اختبار BIOS: احذف سطر -drive."
