#!/bin/bash
# التبديل إلى نواة linux-lts: أكثر استقراراً على الأجهزة القديمة التي يستهدفها زول، وتحديثاتها أهدأ وأقل تكراراً
set -u
[ -d /run/archiso ] && exit 0                       # لا نلمس النواة في النظام الحي (الفلاشة)
pacman -Qq linux-lts >/dev/null 2>&1 || pacman -S --needed --noconfirm linux-lts || exit 1

# حزمة linux-lts تُشغّل mkinitcpio تلقائياً عند تثبيتها (hook)، فنتحقق أن ملفاتها ظهرت فعلاً قبل أي خطوة أخرى
if [ ! -f /boot/vmlinuz-linux-lts ] || [ ! -f /boot/initramfs-linux-lts.img ]; then
    echo "تعذر التأكد من ملفات نواة linux-lts في /boot — لن نزيل النواة القديمة الآن (سيُعاد المحاولة في التحديث القادم)" >&2
    exit 1
fi

# الآن، وبعد أن تأكدنا من وجود نواة بديلة صالحة فعلاً، نزيل النواة العادية إن كانت مثبتة
pacman -Qq linux >/dev/null 2>&1 && { pacman -Rns --noconfirm linux || true; }

command -v grub-mkconfig >/dev/null 2>&1 && grub-mkconfig -o /boot/grub/grub.cfg
exit 0
