<div align="center">

<img src="docs/img/logo.png" width="180" alt="Zool OS">

# Zool OS — زول

**توزيعة لينكس سودانية خفيفة، مبنية على Arch Linux بسطح مكتب Hyprland**

[![Download](https://img.shields.io/badge/تحميل-ISO-e8b04a?style=for-the-badge)](https://github.com/imrnsec/zool-os-arch/releases/latest)
![Arch](https://img.shields.io/badge/Arch-Linux-1793d1?style=for-the-badge&logo=archlinux&logoColor=white)
![Size](https://img.shields.io/badge/الحجم-1.9GB-d46a43?style=for-the-badge)

<img src="docs/img/boot.png" width="640" alt="شاشة الإقلاع">

</div>

---

## لماذا «زول»؟

كلمة **«زول»** بالسودانية تعني «الشخص»، وهي أشهر كلمة تميّز السودانيين في أي مكان.
سُمّي النظام بها ليعرف أي زول يصادفه في أي مكان في العالم أنه نظام سوداني. 🇸🇩

الهوية البصرية مستوحاة من **أهرامات مروي** و**شمس السودان** و**التقاء النيلين** (الأزرق والأبيض) عند المقرن.

## المميزات

- 🪶 **خفيف:** ملف الـ ISO نحو **1.9GB** فقط.
- 🎨 **هوية سودانية متكاملة:** ثيم GRUB خاص بزول ثم شعار زول المتحرك، وشريط علوي عائم يتلوّن مع الثيم.
- 🌈 **خمسة ثيمات جاهزة** تغيّر الألوان والخلفية معاً بضغطة (`SUPER + T`): زول، الفقاعة الزرقاء، أعماق البحر، أفق الدوائر، ديونيسوس — بخلفيات من السودان. ويمكنك إضافة ثيمك في `~/.config/zool/themes/`.
- 🕌 **أوقات الصلاة والتاريخ الهجري** في الشريط العلوي مع إشعار الأذان، وتُحسب محلياً دون إنترنت (`zool-prayer`).
- 🔤 **خطوط عربية مضمّنة:** Reem Kufi للعناوين وAmiri للنصوص إلى جانب Noto.
- 💿 **مثبّت رسومي بالعربية** (`zool-install`) ينقل النظام بثيماته إلى القرص بخطوات بسيطة.
- 🔐 **شاشة دخول SDDM** بهوية زول.
- ⚡ **مهيّأ للأجهزة الضعيفة:** وضع مؤثرات خفيف افتراضياً (يُبدَّل بـ `zool-effects`)، وذاكرة مضغوطة zram، وفك ترميز الفيديو بالعتاد على Intel.
- 🖱️ **سهل بالفأرة:** شريط مهام للنوافذ المفتوحة وزر إغلاق، ومؤشر للصوت والسطوع، وقفل تلقائي عند الخمول.
- 🪟 **Hyprland** مع شريط Waybar وقائمة Wofi وإشعارات Mako بألوان رمل السودان ونيله.
- ⌨️ **مساحات عمل بأرقام عربية**، وتبديل لوحة المفاتيح بين الإنجليزية والعربية بـ `Alt+Shift`.
- 🎬 **وسائط جاهزة:** ترميزات الفيديو والصوت، وقارئ PDF (evince)، وعارض صور (loupe)، ومشغّل (mpv).
- 🛍️ **متجر برامج رسومي** (`zool-store`): برامج مختارة، بحث في مستودعات Arch، و**AUR** عبر `paru`.
- 🔄 **تحديث بلا إعادة تثبيت** (`zool-update`): يجلب آخر مميزات زول من GitHub ويحدّث حزم النظام، مع إشعار عند توفر تحديث.
- 👋 **شاشة ترحيب ومركز إعدادات** للمبتدئ: الشبكة والصوت والوقت وكلمة المرور من مكان واحد.

<div align="center">
<img src="docs/img/nile-sunset.jpg" width="31%" alt="غروب النيل">
<img src="docs/img/meroe-night.jpg" width="31%" alt="ليل مروي">
<img src="docs/img/dune-dawn.jpg" width="31%" alt="فجر الكثبان">
</div>

---

## 📥 التنزيل

1. افتح صفحة **[Releases](https://github.com/imrnsec/zool-os-arch/releases/latest)** ونزّل ملف `zoolos-….iso`.
2. نزّل معه ملف `.sha256` إن أردت التحقق من سلامة الملف:
   ```bash
   sha256sum -c zoolos-*.iso.sha256
   ```

## 🔥 كتابة النظام على فلاشة

> ⚠️ **تنبيه:** هذه الخطوة تمسح كل ما على الفلاشة. تأكد من اسمها قبل البدء.

**من لينكس:**
```bash
lsblk                       # تعرّف على اسم الفلاشة، مثل /dev/sdX
sudo dd if=zoolos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

**من ويندوز:** استخدم [Rufus](https://rufus.ie) واختر وضع **DD Image** عند السؤال، أو [balenaEtcher](https://etcher.balena.io).

## 🚀 الإقلاع والتجربة

1. أعد تشغيل الجهاز واضغط مفتاح قائمة الإقلاع (غالباً `F12` أو `F9` أو `Esc`).
2. اختر الفلاشة. إن ظهر لها بندان فاختر الذي يحمل كلمة **UEFI** أو **EFI** (إن كان جهازك يدعمه).
3. في GRUB اختر **Zool OS** (أو خيار *safe graphics* إن ظهرت شاشة سوداء).
4. سيفتح النظام مباشرة (وضع حي) دون أن يغيّر شيئاً في جهازك.

## 💿 التثبيت على القرص

> ⚠️ **التثبيت يمسح القرص المختار بالكامل.** انسخ ملفاتك المهمة قبل أن تبدأ.

1. من النظام الحي اضغط **`SUPER + Z`** ثم اختر **تثبيت زول**.
2. اختر القرص الهدف، ثم أدخل اسم المستخدم واسم الجهاز وكلمة المرور والمنطقة الزمنية.
3. اختر هل تريد **الدخول التلقائي** (يوصى به إن واجهت مشكلة في شاشة الدخول).
4. أكّد، وانتظر انتهاء التثبيت، ثم أخرج الفلاشة وأعد التشغيل.

سجل التثبيت يُحفظ في `/tmp/zool-install.log` على النظام الحي، وهو مفيد عند الإبلاغ عن مشكلة.

## ⌨️ أهم الاختصارات

| الاختصار | الوظيفة |
|---|---|
| `SUPER + F1` | عرض كل الاختصارات |
| `SUPER + Z` | قائمة زول (التثبيت، مدينة الصلاة، البرامج الإضافية…) |
| `SUPER + Return` | الطرفية (kitty) |
| `SUPER + Space` | قائمة التطبيقات |
| `SUPER + B` / `SUPER + E` | المتصفح / مدير الملفات |
| `SUPER + W` / `ALT + F4` | إغلاق النافذة |
| `SUPER + SHIFT + E` | المؤثرات: خفيف ↔ كامل |
| `SUPER + T` | تغيير الثيم |
| `SUPER + L` | قفل الشاشة |
| `SUPER + Escape` | قائمة الطاقة |
| `Alt + Shift` | تبديل اللغة (EN ↔ عربي) |

## 💻 المتطلبات

- معالج 64-بت (x86_64).
- ذاكرة 2GB على الأقل، والأفضل 4GB.
- مساحة قرص 15GB فأكثر للتثبيت.
- يعمل بوضع **UEFI** و**BIOS (Legacy)**.

## 🛠️ ملاحظات معروفة

- **شاشة سوداء بعد التثبيت على بعض الأجهزة** (جرّبناه على معالج Intel Atom/Celeron القديم): اختر **الدخول التلقائي** أثناء التثبيت.
- المشروع ما زال في مرحلة مبكرة، وقد تجد أخطاء. أخبرنا عنها في [Issues](https://github.com/imrnsec/zool-os-arch/issues) مع صورة للخطأ أو ملف السجل.

## 🗂️ هيكل المستودع

ملفات النظام في جذر المستودع بنفس بنية النظام المثبّت، لتعرف أين تعدّل أي شيء:

| المجلد | يُنسخ إلى | المحتوى |
|---|---|---|
| `bin/` | `/usr/local/bin` | أوامر زول (`zool-install`، `zool-prayer`، `zool-menu`…) |
| `config/` | `/etc/skel/.config` | إعدادات Hyprland وWaybar وWofi وMako وKitty |
| `etc/` | `/etc` | إعدادات النظام (SDDM، systemd، mkinitcpio، Plymouth) |
| `share/` | `/usr/share` | الشعار والخلفيات والخطوط وثيمات Plymouth وSDDM |
| `iso/` | — | إعدادات الـ ISO: الحزم، GRUB، Syslinux |
| `tools/` · `branding/` | — | أدوات البناء ومولّدات الهوية |

## 🔄 التحديث

بعد التثبيت لا تحتاج ISO جديداً للحصول على المميزات الجديدة:

```bash
zool-update          # حزم النظام + آخر ملفات زول من GitHub
zool-update --zool   # ملفات زول فقط
zool-update check    # هل يوجد تحديث؟
```

أو من قائمة زول (`SUPER + Z`) ← «تحديث النظام». إعداداتك التي عدّلتها بنفسك لا تُمسّ.

## 🏗️ البناء من المصدر

```bash
sudo pacman -S --needed archiso git grub squashfs-tools libisoburn mtools dosfstools
git clone -b zool-os-arch https://github.com/imrnsec/zool-os-arch
cd zool-os-arch
bash build-zoolos.sh
```

ينتج الملف `zoolos-….iso` مع مجموعه `.sha256` في المجلد الرئيسي.

يلزم 12GB مساحة حرة على الأقل. التفاصيل الكاملة (بما فيها البناء داخل Docker من أي توزيعة) في [`docs/BUILD.md`](docs/BUILD.md).

## 🤝 المساهمة

الأفكار والتصاميم والترجمات وإصلاحات الأخطاء كلها مرحّب بها. افتح Issue أو Pull Request.

## 📜 الترخيص

ألوان الثيمات الإضافية مقتبسة من ثيمات Omarchy: [Blue Bubble](https://github.com/biggsjm/omarchy-blue-bubble-theme) (Josh Biggs، MIT)، [Cthulhu Deep One](https://github.com/sonderbydk/omarchy-cthulhu-deep-one-theme) (sonderbydk، MIT)، [Circuit Horizon](https://github.com/jennabrinning/omarchy-circuit-horizon-theme) (Jenna Brinning، MIT)، [Dionysus](https://github.com/joeyvigil/omarchy-dionysus-theme) (joeyvigil). الخطوط Amiri وReem Kufi تحت رخصة OFL ونصوصها مرفقة في مجلد الخطوط.

## 📬 تواصل معي

<div align="center">

[![Instagram](https://img.shields.io/badge/Instagram-@imrn.sec-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/imrn.sec)
[![X](https://img.shields.io/badge/X-@imrnsec-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/imrnsec)

</div>

---

<details>
<summary><b>English summary</b></summary>

**Zool OS** is a lightweight (~1.9 GB ISO) Sudanese-themed Linux distribution based on Arch Linux with the Hyprland Wayland compositor. "Zool" (زول) is Sudanese Arabic for "person" and is the most recognisable word of the Sudanese dialect.

**Features:** Arabic-first GUI installer, offline prayer times + Hijri date in Waybar with adhan notification, bundled Arabic fonts (Reem Kufi, Amiri, Noto), SDDM login theme, a custom Zool GRUB theme and boot animation, five switchable colour themes, a graphical app store with AUR (paru), and in-place updates from GitHub (`zool-update`), media codecs, PDF/image viewers, and optional LibreOffice.

**Download:** grab the ISO from [Releases](https://github.com/imrnsec/zool-os-arch/releases/latest), write it with `dd` (Linux) or Rufus in DD mode (Windows), boot it in UEFI or BIOS mode, then press `SUPER + Z` → *Install Zool OS*. The installer erases the selected disk.

**Build:** see [`docs/BUILD.md`](docs/BUILD.md).

**Follow:** [Instagram @imrn.sec](https://instagram.com/imrn.sec) · [X @imrnsec](https://x.com/imrnsec)

</details>
