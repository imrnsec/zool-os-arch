#!/bin/bash
# طرفية تدعم العربية من اليمين لليسار + حزمة اللغة العربية لفايرفوكس
pacman -S --needed --noconfirm lxterminal firefox-i18n-ar || exit 1
exit 0
