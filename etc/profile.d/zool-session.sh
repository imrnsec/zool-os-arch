# Zool OS — يبدأ سطح المكتب (Hyprland) تلقائياً عند الدخول على tty1
# للخروج إلى الطرفية النصية: سجّل الدخول على tty آخر (Ctrl+Alt+F3)
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ -z "${DISPLAY:-}" ] && [ "$(id -u)" -ne 0 ] && [ "$(tty 2>/dev/null)" = /dev/tty1 ]; then
    _zool_t0=$(date +%s)
    if command -v start-hyprland >/dev/null 2>&1; then
        start-hyprland >/dev/null 2>&1
    else
        Hyprland >/dev/null 2>&1
    fi
    _zool_rc=$?
    # خروج طبيعي بعد جلسة فعلية = تسجيل خروج. أما إن فشل الإقلاع سريعاً فنبقى في الطرفية للتشخيص (ولا ندخل في حلقة)
    if [ "$_zool_rc" -eq 0 ] && [ $(( $(date +%s) - _zool_t0 )) -ge 10 ]; then
        exit 0
    fi
    echo
    echo "تعذر تشغيل سطح المكتب (رمز $_zool_rc). جرّب:  start-hyprland   أو راجع السجل:  journalctl -b --user | tail -50"
    unset _zool_t0 _zool_rc
fi
