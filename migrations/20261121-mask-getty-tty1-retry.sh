#!/bin/bash
# إصلاح ثانٍ لنفس مشكلة سباق tty1: الترحيل السابق (20261119) استخدم "systemctl disable" فقط،
# لكن systemd-getty-generator يُعيد توليد وحدة getty@tty1 تلقائياً في كل إقلاع من جديد (وحدة runtime)،
# فـ"disable" وحده لا يمنعها من العودة — تحتاج "mask" فعلياً لتبقى معطّلة بشكل دائم عبر الإقلاعات.
# هذا الترحيل يُعاد تطبيقه بشرط وجود /etc/greetd/config.toml (أي أن شاشة دخول زول مفعَّلة فعلاً)
# بصرف النظر عن نتيجة الترحيل السابق، لأن ذاك قد يكون "نجح" ظاهرياً دون أن يحل المشكلة فعلياً.
[ -f /etc/greetd/config.toml ] || exit 0
systemctl disable --now getty@tty1.service 2>/dev/null || true
systemctl mask getty@tty1.service 2>/dev/null || true
systemctl enable greetd.service 2>/dev/null || true
exit 0
