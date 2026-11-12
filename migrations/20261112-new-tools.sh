#!/bin/bash
# حزم وخدمات أُضيفت بعد إصدارات زول الأولى: أدوات الحزم (fzf)، الضوء الليلي، أوضاع الطاقة،
# الذاكرة المضغوطة (zram)، والجدار الناري. آمن عند إعادة التشغيل.
pacman -S --needed --noconfirm fzf hyprsunset hypridle power-profiles-daemon zram-generator ufw || exit 1
systemctl enable --now power-profiles-daemon.service 2>/dev/null || true
sed -i 's/^ENABLED=no/ENABLED=yes/' /etc/ufw/ufw.conf 2>/dev/null || true
systemctl enable ufw.service 2>/dev/null || true
ufw --force enable >/dev/null 2>&1 || true
exit 0
