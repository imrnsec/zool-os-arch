#!/bin/bash
# Zool Terminal (VTE) + zsh صدفةً افتراضية للمستخدمين الحاليين
pacman -S --needed --noconfirm vte3 python-gobject zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting || exit 1
while IFS=: read -r user _ uid _ _ home shell; do
    [ "$uid" -ge 1000 ] && [ "$uid" -lt 60000 ] && [ -d "$home" ] || continue
    if [ ! -e "$home/.zshrc" ] && [ -f /etc/skel/.zshrc ]; then
        install -o "$user" -g "$(id -gn "$user")" -m 644 /etc/skel/.zshrc "$home/.zshrc"
    fi
    case "$shell" in */bash) chsh -s /bin/zsh "$user" >/dev/null 2>&1 || true ;; esac
done < /etc/passwd
exit 0
