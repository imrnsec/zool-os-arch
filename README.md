# Zool OS — زول

توزيعة Linux سودانية مبنية على **Arch Linux** بسطح مكتب **Hyprland**، بهوية مستوحاة من أهرامات مروي وشمس السودان والتقاء النيلين.

> الاسم السابق للمشروع: SnlnOS. اسم المستودع ما زال `snlnos`.

## الحالة
مرحلة تطوير مبكرة — الملفات جاهزة للبناء ولم تُختبر بعد على جهاز فعلي.

## البناء
```bash
sudo pacman -S --needed archiso git grub squashfs-tools libisoburn mtools dosfstools qemu-desktop edk2-ovmf
bash build-zoolos.sh
```
التفاصيل الكاملة في [`docs/BUILD.md`](docs/BUILD.md).

## المميزات
- GRUB بثيم YoRHa ← أنيميشن شعار زول ← دخول تلقائي إلى Hyprland
- شريط Waybar وقائمة Wofi وإشعارات Mako بألوان رمل السودان ونيله
- مساحات عمل بأرقام عربية، وتبديل لغة EN/عربي (`Alt+Shift`)
- ثلاث خلفيات سودانية (غروب النيل · ليل مروي · فجر الكثبان)

## الترخيص
(حدد الترخيص المناسب هنا). ثيم GRUB (YoRHa) من تأليف OliveThePuffin ويُنزَّل وقت البناء.
