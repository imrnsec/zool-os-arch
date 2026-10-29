#!/bin/bash
# ═══════════════════════════════════════════════
#  سكربت بناء توزيعة snlnOs
#  التشغيل:  bash build-snlnos.sh
#  يجب تشغيله داخل مجلد المشروع (حيث يوجد config/)
# ═══════════════════════════════════════════════
set -e   # توقف فوراً عند أي خطأ

echo "═══ [1/3] إعداد الإعدادات (lb config) ═══"
lb config \
  --distribution bookworm \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --bootloaders "syslinux,grub-efi" \
  --debian-installer live \
  --bootappend-live "boot=live components quiet splash hostname=snlnos username=snln timezone=Africa/Khartoum locales=ar_SD.UTF-8,en_US.UTF-8 keyboard-layouts=us,ara"

echo "═══ [2/3] بناء النظام (قد يستغرق 20-60 دقيقة) ═══"
sudo lb build

echo "═══ [3/3] اكتمل البناء! ═══"
echo "ملف الـ ISO الناتج: $(ls *.iso 2>/dev/null || echo 'لم يُنتج ملف - راجع الأخطاء أعلاه')"
echo ""
echo "اختبار وضع UEFI (التصميم الجديد):"
echo "  qemu-system-x86_64 -bios /usr/share/qemu/OVMF.fd -cdrom snlnos-*.iso -m 4096 -enable-kvm"
echo "اختبار وضع BIOS:"
echo "  qemu-system-x86_64 -cdrom snlnos-*.iso -m 4096 -enable-kvm"
