#!/bin/bash
# ═══════════════════════════════════════════════
#  سكربت بناء Zool OS (زول) — Arch + Hyprland
#  التشغيل:  bash build-zoolos.sh
#  المدخلات: ملفات النظام في المجلد الرئيسي (bin config etc share iso) — انظر tools/assemble-profile.sh
#  المخرجات: zoolos-*.iso و zoolos-*.iso.sha256 في المجلد الرئيسي (ونسخة في out/)
#  يجب تشغيله على Arch Linux (جهاز أو VM أو حاوية archlinux --privileged)
# ═══════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"
WORK="${ZOOL_WORK:-/var/tmp/zoolos-work}"
OUT="${ZOOL_OUT:-$PWD/out}"
PROFILE="${ZOOL_PROFILE:-$PWD/build/profile}"   # يُولَّد من المجلدات الرئيسية، لا تعدّله يدوياً

echo "═══ [0/5] فحص المتطلبات ═══"
if [ ! -f /etc/arch-release ]; then
  echo "✗ هذا السكربت يعمل على Arch Linux فقط (أو حاوية archlinux)."
  echo "  على غير Arch: docker run --rm --privileged -v \"\$PWD\":/zool -w /zool archlinux bash -c 'pacman -Syu --noconfirm archiso git grub squashfs-tools libisoburn mtools dosfstools && bash build-zoolos.sh'"
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
MIN_GB="${ZOOL_MIN_GB:-12}"
[ "${free_gb:-0}" -ge "$MIN_GB" ] || { echo "✗ المساحة الحرة ${free_gb}GB في $(dirname "$WORK") — يلزم ${MIN_GB}GB على الأقل."; echo "  (في Docker: أضف --rm، ونظّف بـ  docker system prune -a ، أو غيّر المسار بـ ZOOL_WORK)"; exit 1; }

echo "═══ [1/5] تجهيز ثيم GRUB (زول) ═══"
bash tools/make-grub-theme.sh

echo "═══ [2/5] تجميع ملفات النظام (bin · config · etc · share · iso) ═══"
bash tools/assemble-profile.sh "$PROFILE"
$SUDO rm -rf "$WORK"
mkdir -p "$OUT"

echo "═══ [3/5] بناء الـ ISO (قد يستغرق 15-40 دقيقة؛ السجل في build.log) ═══"
$SUDO mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE" 2>&1 | tee build.log

echo "═══ [4/5] اكتمل البناء! ═══"
ISO="$(ls -1t "$OUT"/zoolos-*.iso 2>/dev/null | head -1)"
if [ -z "$ISO" ]; then
  echo "✗ لم يُنتج ملف ISO — راجع آخر 40 سطراً من build.log"
  exit 1
fi
( cd "$OUT" && sha256sum "$(basename "$ISO")" | tee "$(basename "$ISO").sha256" )

echo "═══ [5/5] إظهار النتائج في المجلد الرئيسي ═══"
# ملفات النظام (bin/ config/ etc/ share/ iso/ …) موجودة أصلاً في المجلد الرئيسي،
# ونضع هنا نسخة الـ ISO ومجموعها بجانبها ليسهل الوصول إليها.
ROOT_DIR="$PWD"
if [ "$(readlink -f "$OUT")" != "$ROOT_DIR" ]; then
  rm -f "$ROOT_DIR"/zoolos-*.iso "$ROOT_DIR"/zoolos-*.iso.sha256
  cp -f "$ISO" "$ISO.sha256" "$ROOT_DIR"/
fi
FINAL="$ROOT_DIR/$(basename "$ISO")"
echo "  ملفات النظام في: $ROOT_DIR/{bin,config,etc,share,iso}"
echo "  الـ ISO + المجموع في: $ROOT_DIR/"
ls -lh "$ROOT_DIR"/zoolos-*.iso "$ROOT_DIR"/zoolos-*.iso.sha256 2>/dev/null | sed 's/^/    /'
echo ""
echo "ملف الـ ISO: $FINAL"
echo ""
echo "اختبار في QEMU (UEFI + تسريع رسوميات — Hyprland يحتاجه):"
echo "  qemu-system-x86_64 -enable-kvm -cpu host -m 4096 -smp 2 -cdrom $FINAL \\"
echo "    -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \\"
echo "    -device virtio-vga-gl -display gtk,gl=on"
echo ""
echo "اختبار BIOS: احذف سطر -drive."
