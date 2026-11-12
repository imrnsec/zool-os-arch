#!/usr/bin/env bash
# shellcheck disable=SC2034
# ملف تعريف archiso لتوزيعة Zool OS (زول)

iso_name="zoolos"
iso_label="ZOOLOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Zool OS Project <https://github.com/imrnsec/zool-os-arch>"
iso_application="Zool OS Live/Install Medium"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.grub')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/sudoers.d/10-zool-wheel"]="0:0:440"
  ["/root"]="0:0:750"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/zool-live-setup"]="0:0:755"
  ["/usr/local/bin/zool-install"]="0:0:755"
  ["/usr/local/bin/zool-power"]="0:0:755"
  ["/usr/local/bin/zool-keys"]="0:0:755"
  ["/usr/local/bin/zool-menu"]="0:0:755"
  ["/usr/local/bin/zool-screenshot"]="0:0:755"
  ["/usr/local/bin/zool-wallpaper"]="0:0:755"
  ["/usr/local/bin/zool-blueman-launch"]="0:0:755"
  ["/usr/local/bin/zool-prayer"]="0:0:755"
  ["/usr/local/bin/zool-theme"]="0:0:755"
  ["/usr/local/bin/zool-update"]="0:0:755"
  ["/usr/local/bin/zool-welcome"]="0:0:755"
  ["/usr/local/bin/zool-theme-install"]="0:0:755"
  ["/usr/local/bin/zool-theme-remove"]="0:0:755"
  ["/usr/local/bin/zool-show-done"]="0:0:755"
  ["/usr/local/bin/zool-launch-terminal"]="0:0:755"
  ["/usr/local/bin/zool-pkg-install"]="0:0:755"
  ["/usr/local/bin/zool-pkg-aur-install"]="0:0:755"
  ["/usr/local/bin/zool-pkg-remove"]="0:0:755"
  ["/usr/local/bin/zool-pkg-add"]="0:0:755"
  ["/usr/local/bin/zool-timezone"]="0:0:755"
  ["/usr/local/bin/zool-effects"]="0:0:755"
  ["/usr/local/bin/zool-osd"]="0:0:755"
  ["/usr/local/bin/zool-idle"]="0:0:755"
)
