#!/bin/bash
# حذف kitty (طرفية زول هي الوحيدة) + ~/.zshrc الجديد الذي يقرأ ألوان النظام
if pacman -Qq kitty >/dev/null 2>&1 && [ -x /usr/local/bin/zool-terminal ] && pacman -Qq vte3 python-gobject >/dev/null 2>&1; then
    pacman -Rns --noconfirm kitty || true
fi
OLD=9558034949d3fbce1482774e917e462c1839517ae5a2e640e1fe5827b3ebad17      # ~/.zshrc الافتراضي السابق (لم يعدّله المستخدم)
while IFS=: read -r user _ uid _ _ home _; do
    [ "$uid" -ge 1000 ] && [ "$uid" -lt 60000 ] && [ -d "$home" ] || continue
    rc="$home/.zshrc"
    if [ ! -e "$rc" ] || [ "$(sha256sum "$rc" | cut -d' ' -f1)" = "$OLD" ]; then
        install -o "$user" -g "$(id -gn "$user")" -m 644 /etc/skel/.zshrc "$rc"
    elif ! grep -q '/usr/share/zool/default/zsh/rc' "$rc"; then
        # عدّله المستخدم: نبقيه ونضيف ألوان زول في آخره
        printf '\n# ألوان وإعدادات زول\n[ -r /usr/share/zool/default/zsh/rc ] && source /usr/share/zool/default/zsh/rc\n' >> "$rc"
    fi
done < /etc/passwd
exit 0
