# snlnOS — دليل البناء

> توزيعة لينكس تعليمية سودانية. الشعار: **Learn. Practice. Secure.**
> سطح المكتب: **Hyprland** (طراز Omarchy بألوان الهوية) على **Debian 13 (trixie)**.

---

## 📖 مفردات أساسية

| المصطلح | معناه ببساطة |
|---------|---------------|
| **ISO** | ملف القرص الذي تحرقه على USB — هو "صورة" التوزيعة |
| **live-build (lb)** | أداة Debian التي تبني التوزيعة وتنفّذ ملفات `config/` |
| **chroot** | نظام مصغّر يُبنى داخل جهازك أثناء البناء |
| **hook** | سكربت يعمل تلقائياً أثناء البناء |
| **includes.chroot** | كل ما يوضع هنا يُنسخ كما هو إلى داخل التوزيعة |
| **backports** | مستودع Debian لحزم أحدث؛ منه نأخذ Hyprland |

---

## 🚀 البناء (أول مرة)

يلزم جهاز **Debian 13** (أو VM أو حاوية `debian:trixie --privileged`) بمساحة حرة 20GB+ وإنترنت.

```bash
# 1) المتطلبات
sudo apt update
sudo apt install live-build debootstrap squashfs-tools xorriso \
     grub-pc-bin grub-efi-amd64-bin mtools dosfstools \
     qemu-system-x86 ovmf git

# 2) انسخ المشروع
git clone -b import-project-v7 https://github.com/imrnsec/snlnos
cd snlnos

# 3) ابنِ (30–90 دقيقة؛ السجل في build.log)
bash build-snlnos.sh

# 4) اختبر دون حرق USB (Hyprland يحتاج virtio-vga-gl)
qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 -cdrom snlnos-amd64.hybrid.iso \
    -device virtio-vga-gl -display gtk,gl=on
```

> ⚠️ لا تستخدم `-vga qxl` — Hyprland لا يعمل جيداً عليه.
> ⚠️ على Ubuntu أو Debian 12 قد يفشل البناء (إصدار live-build/debootstrap أقدم).

---

## ⌨️ اختصارات سطح المكتب

اضغط **SUPER + F1** داخل النظام لعرضها. أهمها:

| الاختصار | الوظيفة |
|----------|---------|
| `SUPER + Enter` | الطرفية |
| `SUPER + Space` | قائمة التطبيقات |
| `SUPER + B` / `E` | المتصفح / الملفات |
| `SUPER + W` | إغلاق النافذة |
| `SUPER + 1..9` | مساحات العمل |
| `SUPER + L` | قفل الشاشة |
| `SUPER + Esc` | قائمة الطاقة |
| `Print` | لقطة منطقة |
| `Alt + Shift` | تبديل اللغة EN/عربي |

---

## 🗂️ خريطة المشروع

```
snlnos/
├── build-snlnos.sh        ← زر البناء (يفحص المتطلبات ثم يبني ويحسب SHA256)
├── auto/config            ← كل خيارات live-build (التوزيعة، الـ ISO، معاملات الإقلاع)
├── docs/BUILD.md          ← هذا الملف
└── config/
    ├── archives/          ← مستودع trixie-backports + تثبيت (pin) حزم Hyprland منه
    ├── package-lists/
    │   └── snln.list.chroot   ← الحزم المثبّتة
    ├── hooks/normal/
    │   ├── 1000-snln-branding.hook.chroot  ← Plymouth + SDDM + الأذونات
    │   ├── 2000-snln-liveboot.hook.binary  ← ثيم قائمة الإقلاع (GRUB/syslinux)
    │   └── 3000-snln-tweaks.hook.chroot    ← تسريع الإقلاع + فحص جلسة Hyprland
    └── includes.chroot/
        ├── etc/skel/.config/   ← hypr · waybar · wofi · mako · foot · gtk (إعدادات المستخدم)
        ├── etc/sddm.conf.d/    ← دخول تلقائي في نظام الحياة
        ├── etc/default/grub.d/ ← إعدادات GRUB
        ├── boot/grub/themes/snln/  ← ثيم GRUB
        └── usr/
            ├── local/bin/      ← snln-power · snln-keys · snln-screenshot
            └── share/          ← backgrounds · logo · plymouth
```

---

## 🛠️ حل المشاكل المتوقعة

**فشل تثبيت Hyprland (`unmet dependencies` / `libxkbcommon0`)**
Hyprland يأتي من backports ويحتاج مكتبات أحدث. افتح `config/archives/trixie-backports.pref.chroot` وأضف اسم المكتبة التي ذكرتها الرسالة إلى سطر `Package:` ثم أعد البناء.

**البناء يتوقف عند "hyprland.desktop غير موجود"**
يعني أن الحزمة لم تُثبَّت من backports. راجع `build.log` وتأكد من وجود `trixie-backports` في ملف `config/archives/trixie-backports.list.chroot`.

**شاشة سوداء أو أخطاء في VM**
استخدم `virtio-vga-gl` مع `-display gtk,gl=on`. على VirtualBox فعّل "3D Acceleration" ومحوّل VMSVGA.

**الحاجة لإعادة البناء من الصفر**
`sudo lb clean` (يحذف chroot/binary لكن يُبقي كاش الحزم). للحذف الكامل: `sudo lb clean --purge`.

---

## ✅ ترتيب المهام المقترح

- [ ] بناء أول ISO ناجح واختباره في QEMU
- [ ] التأكد من: الإقلاع ← الدخول التلقائي ← Waybar ← wofi ← الطرفية
- [ ] ثيم SDDM مخصص (للنظام المثبّت)
- [ ] استبدال الخلفيات بصور سودانية مرخّصة
- [ ] تثبيت Calamares (المثبّت) وإزالة الدخول التلقائي من النظام المثبّت
- [ ] إضافة أدوات الأمن السيبراني (Nmap, tshark, ...) بحسب اتجاه المشروع
- [ ] الإصدار التجريبي v0.1

---

## ⚠️ قواعد ذهبية

1. ابنِ دائماً داخل **جهاز افتراضي أو حاوية**، لا على نظامك اليومي.
2. انشر ملف `.sha256` مع كل ISO (ينتجه سكربت البناء).
3. كل صورة تضيفها يجب أن تكون مرخّصة.
4. لا ترفع `chroot/` أو `binary/` أو `*.iso` إلى Git (محمية في `.gitignore`).

---

## 🔄 سجل التغييرات

### الإصدار 0.4 — الانتقال إلى Hyprland
- القاعدة: Debian 13 (trixie) بدل bookworm
- سطح المكتب: Hyprland + Waybar + Wofi + Mako + Foot بألوان الهوية (بدل XFCE/LightDM)
- مدير الدخول: SDDM مع دخول تلقائي في نظام الحياة
- الصوت: PipeWire بدل PulseAudio
- أدوات جديدة: `snln-power` و`snln-keys` و`snln-screenshot`
- ملف الـ ISO الناتج باسم `snlnos-amd64.hybrid.iso` + SHA256
- نقل خيارات البناء إلى `auto/config`، وتحديث `.gitignore` لملفات البناء
- إزالة `fonts-noto-cjk` لتقليل الحجم

### الإصدار 0.3 — إصلاحات ما بعد أول اختبار
- Plymouth عبر plymouthd.conf، تخصيص قائمة الإقلاع، هوية المستخدم، دعم العربية

### الإصدار 0.2 — الهوية المصممة
- خلفيات سودانية مولّدة، ثيم GRUB، شاشة إقلاع Plymouth متحركة
