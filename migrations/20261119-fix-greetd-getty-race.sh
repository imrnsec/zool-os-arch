#!/bin/bash
# إصلاح: الإصدار السابق من zool-login-setup لم يكن يعطّل getty@tty1 عند تفعيل شاشة دخول زول،
# فتسابقت الخدمتان على نفس الطرفية — أحياناً يظهر موجه دخول نصي بدل شاشة زول الرسومية.
if systemctl is-enabled greetd.service >/dev/null 2>&1; then
    systemctl disable --now getty@tty1.service 2>/dev/null || true
fi
exit 0
