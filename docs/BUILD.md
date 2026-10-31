# Zool OS (زول) — دليل البناء

> **زول** بالسودانية = «الشخص». توزيعة لينكس سودانية على **Arch Linux** بسطح مكتب **Hyprland**.
> الهوية: أهرامات مروي + شمس السودان + التقاء النيلين (الأزرق والأبيض) عند المقرن.

---

## 🚀 البناء

يلزم جهاز **Arch Linux** (أو VM، أو حاوية `archlinux --privileged`) بمساحة حرة 20GB+ وإنترنت.

```bash
# 1) المتطلبات
sudo pacman -S --needed archiso git grub squashfs-tools libisoburn mtools dosfstools qemu-desktop edk2-ovmf

# 2) انسخ المشروع
git clone -b zool-os-arch https://github.com/imrnsec/zool-os-arch
cd zool-os-arch

# 3) ابنِ (15–40 دقيقة؛ السجل في build.log)
bash build-zoolos.sh
```

الناتج: `out/zoolos-YYYY.MM.DD-x86_64.iso` ومعه ملف `.sha256`.

**اختبار بدون حرق USB** (Hyprland يحتاج تسريع رسوميات، لذلك `virtio-vga-gl`):
```bash
qemu-system-x86_64 -enable-kvm -cpu host -m 4096 -smp 2 -cdrom out/zoolos-*.iso \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
  -device virtio-vga-gl -display gtk,gl=on
```
> على VirtualBox: فعّل «3D Acceleration» واختر المحوّل VMSVGA. لا تستخدم QXL.

**على غير Arch** (Docker):
```bash
docker run --privileged --rm -v "$PWD":/zool -w /zool archlinux \
  bash -c 'pacman -Syu --noconfirm archiso git grub squashfs-tools libisoburn mtools dosfstools && bash build-zoolos.sh'
```

---

## 🎬 ما سيظهر عند الإقلاع

1. **GRUB** بثيم **YoRHa** (يُنزَّل وقت البناء، النصوص معدّلة إلى «Z O O L  O S»).
2. **شعار زول المتحرك** (Plymouth): يظهر الشعار، تشرق الشمس خلف الأهرامات، تدور الأشعة ببطء، يظهر الاسم مع نقاط تحميل نابضة.
3. **دخول تلقائي** إلى Hyprland (مستخدم `zool` بلا كلمة مرور في نظام الحياة).

---

## 🎨 الثيم السوداني الناعم

| اللون | القيمة | مصدره |
|-------|--------|-------|
| ليل النيل (الخلفية) | `#10181c` | سماء الليل فوق النيل |
| رمل (النص) | `#f3e6cc` | كثبان الصحراء |
| ذهب (التمييز) | `#e8b04a` | شمس السودان |
| طوب مروي | `#d46a43` | أهرامات مروي |
| تيل | `#3ba5a0` | التقاء النيلين |
| هجليج | `#8fb35f` | شجر الهجليج |

- **الشريط (Waybar):** جزر ناعمة مدوّرة، مساحات عمل بأرقام عربية (١ ٢ ٣ …)، شعار زول، تاريخ بالعربية.
- **قائمة التطبيقات (Wofi):** بطاقة شفافة بثلاثة أعمدة، شريط بحث على شكل حبة، تحديد ذهبي. `SUPER+Space`.
- **قائمة زول (`SUPER+Z`):** اختصارات للشبكة والبلوتوث والصوت والخلفية والتثبيت.
- **ثلاث خلفيات:** `nile-sunset` (الافتراضية) · `meroe-night` · `dune-dawn`. تغييرها: `SUPER+SHIFT+W`.
- **GTK/Kitty/Mako/Hyprlock:** كلها بالألوان نفسها.

---

## ⌨️ الاختصارات

اضغط **SUPER + F1** داخل النظام. أهمها: `SUPER+Enter` طرفية · `SUPER+Space` تطبيقات · `SUPER+Z` قائمة زول · `SUPER+W` إغلاق · `SUPER+1..9` مساحات العمل · `SUPER+L` قفل · `SUPER+Esc` الطاقة · `Alt+Shift` تبديل اللغة (EN/عربي).

---

## 🗂️ خريطة المشروع

```
├── build-zoolos.sh             ← زر البناء
├── profile/                    ← ملف تعريف archiso
│   ├── profiledef.sh · pacman.conf · packages.x86_64
│   ├── grub/grub.cfg           ← قائمة GRUB (الثيم يُنزَّل إلى grub/themes/yorha)
│   ├── syslinux/               ← قائمة BIOS بهوية زول
│   └── airootfs/               ← ملفات النظام الحي
│       ├── etc/skel/.config/   ← hypr · waybar · wofi · mako · kitty · gtk · fastfetch
│       ├── etc/mkinitcpio.conf.d/archiso.conf   ← فيه hook الـ plymouth
│       └── usr/
│           ├── local/bin/      ← zool-menu · zool-power · zool-keys · zool-wallpaper · …
│           └── share/{zool,plymouth/themes/zool}   ← الشعار والخلفيات وأنيميشن الإقلاع
├── branding/                   ← مولّدات الهوية (الشعار، الخلفيات)
└── tools/fetch-grub-theme.sh   ← ينزّل ثيم YoRHa
```

### إعادة توليد الشعار والخلفيات
```bash
cd branding
pip install uharfbuzz fonttools brotli playwright && playwright install chromium
npm i @fontsource/outfit @fontsource/reem-kufi
python3 make_logo.py          # الشعار + طبقات الأنيميشن + الاسم
python3 make_wallpapers.py    # الخلفيات الثلاث
```

---

## 🛠️ حل المشاكل المتوقعة

**فشل `mkarchiso` بسبب اسم حزمة:** افتح `build.log` وابحث عن `target not found`، ثم احذف الحزمة أو بدّلها في `profile/packages.x86_64`.

**الإقلاع يتجمد عند شاشة الشعار:** جرّب الخيار «safe graphics (nomodeset)» من قائمة GRUB. إن نجح فالمشكلة في تعريف الرسوميات داخل الـ VM.

**شاشة سوداء بعد الشعار:** يعني أن Hyprland لم يبدأ (غالباً بلا تسريع رسوميات). اضغط `Ctrl+Alt+F2` وادخل بالمستخدم `zool` (بلا كلمة مرور)، ثم شغّل `Hyprland` لقراءة رسالة الخطأ.

**لا يظهر ثيم GRUB:** تأكد أن `tools/fetch-grub-theme.sh` نجح (يحتاج إنترنت) وأن المجلد `profile/grub/themes/yorha` موجود قبل البناء.

---

## ⚠️ ملاحظات

- **ترخيص ثيم YoRHa:** مستودعه الأصلي بلا ملف ترخيص صريح، لذلك لا يُضمَّن في هذا المستودع ويُنزَّل وقت البناء. قبل أي إصدار عام راسل المؤلف أو استبدله.
- **المثبّت:** يستخدم `archinstall` الرسمي (`zool-install`). تخصيصات زول لا تنتقل تلقائياً للنظام المثبّت بعد؛ هذه مهمة قادمة (Calamares أو سكربت ما بعد التثبيت).
- **الدخول التلقائي** خاص بنظام الحياة ويجب ألا يبقى في النظام المثبّت.

---

## ✅ المهام القادمة

- [ ] أول بناء ناجح واختباره في QEMU
- [ ] التأكد من: GRUB ← شعار زول ← الدخول التلقائي ← Waybar ← Wofi
- [ ] ثيم SDDM بهوية زول (للنظام المثبّت)
- [ ] مثبّت يحمل تخصيصات زول (Calamares أو post-install)
- [ ] مستودع حزم لمحتوى زول التعليمي وأدوات الأمن (على نمط ما خطّطنا له)
- [ ] إصدار تجريبي v0.1 مع SHA256

---

## 🔄 سجل التغييرات

### 0.5 — Zool OS على Arch
- تحويل المشروع إلى Arch (archiso) وتغيير الاسم من snlnOS إلى **Zool OS (زول)**
- شعار جديد (أهرامات مروي + شمس + النيلان) وأنيميشن إقلاع Plymouth
- ثيم GRUB: YoRHa
- ثيم سطح مكتب سوداني ناعم، وإعادة تصميم Waybar وWofi وقائمة زول
- ثلاث خلفيات سودانية مولّدة
