#!/bin/bash
# شاشة دخول زول (greetd) بدل «دخول تلقائي + قفل» — فقط لمن اختار طلب كلمة المرور عند التثبيت
ls /home/*/.config/zool/lock-on-start >/dev/null 2>&1 || exit 0
pacman -S --needed --noconfirm greetd cage || exit 1
/usr/local/bin/zool-login-setup screen || exit 1
exit 0
