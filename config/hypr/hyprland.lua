-- ═══════════════════════════════════════════════
--  Zool OS (زول) — إعدادات Hyprland (صيغة Lua، لـ Hyprland 0.55+)
--  اضغط SUPER + F1 لعرض كل الاختصارات
--
--  ملاحظة: كل أمر خطر محاط بـ pcall حتى لا يُسقط خطأ واحد بقية الإعدادات.
--  الأخطاء تظهر في:  hyprctl configerrors   أو في سجل Hyprland.
-- ═══════════════════════════════════════════════

local function try(label, fn)
    local ok, err = pcall(fn)
    if not ok then
        print("zool: failed -> " .. label .. " : " .. tostring(err))
    end
end

-- يربط اختصاراً؛ make دالة تُنشئ الأمر (لتُلتقط أخطاؤها أيضاً)
local function B(keys, make, opts)
    try("bind " .. keys, function()
        if opts then
            hl.bind(keys, make(), opts)
        else
            hl.bind(keys, make())
        end
    end)
end

local function X(cmd)
    return function() return hl.dsp.exec_cmd(cmd) end
end

-- ── البرامج ──
local terminal = "kitty"
local files    = "thunar"
local browser  = "firefox"
local menu     = "wofi --show drun"

-- ── ألوان زول ──
local gold       = "rgba(e8b04aff)"
local terracotta = "rgba(d46a43ff)"
local inactive   = "rgba(213039aa)"

-- ── الشاشة ──
try("monitor", function()
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
end)

-- ── البرامج التي تبدأ مع الجلسة (أولاً، حتى تعمل مهما حدث بعدها) ──
hl.on("hyprland.start", function()
    for _, cmd in ipairs({
        "zool-wallpaper",
        "waybar",
        "mako",
        "zool-prayer daemon",
        "nm-applet --indicator",
        "zool-blueman-launch",
        "systemctl --user start hyprpolkitagent",
        "wl-paste --watch cliphist store",
        "sh -c 'sleep 4; notify-send -i /usr/share/zool/logo/zool-logo-128.png \"مرحباً بك في زول\" \"اضغط SUPER + F1 لعرض الاختصارات\"'",
    }) do
        try("autostart " .. cmd, function() hl.exec_cmd(cmd) end)
    end
end)

-- ── البيئة ──
try("env", function()
    hl.env("XCURSOR_SIZE", "24")
    hl.env("XCURSOR_THEME", "Adwaita")
    hl.env("MOZ_ENABLE_WAYLAND", "1")
    hl.env("QT_QPA_PLATFORM", "wayland;xcb")
    hl.env("XDG_SESSION_TYPE", "wayland")
end)

-- ── المظهر الناعم ──
try("general+decoration", function()
    hl.config({
        general = {
            gaps_in = 6,
            gaps_out = 14,
            border_size = 2,
            layout = "dwindle",
            resize_on_border = true,
            col = {
                active_border   = { colors = { gold, terracotta }, angle = 45 },
                inactive_border = inactive,
            },
        },
        decoration = {
            rounding = 14,
            active_opacity = 1.0,
            inactive_opacity = 0.93,
            blur = { enabled = true, size = 8, passes = 3, noise = 0.02, brightness = 1.0 },
            shadow = { enabled = true, range = 18, render_power = 3, color = "rgba(00000099)" },
        },
        animations = { enabled = true },
    })
end)

try("animations", function()
    hl.curve("soft",     { type = "bezier", points = { { 0.22, 1 },   { 0.36, 1 } } })
    hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
    hl.animation({ leaf = "windows",    enabled = true, speed = 6,  bezier = "overshot", style = "slide" })
    hl.animation({ leaf = "windowsOut", enabled = true, speed = 5,  bezier = "soft",     style = "slide" })
    hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
    hl.animation({ leaf = "fade",       enabled = true, speed = 6,  bezier = "soft" })
    hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "soft",     style = "slidefade" })
end)

try("dwindle+misc", function()
    hl.config({
        dwindle = { preserve_split = true },
        misc = {
            disable_hyprland_logo = true,
            disable_splash_rendering = true,
            force_default_wallpaper = 0,
        },
    })
end)

-- ── الإدخال: إنجليزي + عربي (Alt+Shift للتبديل) ──
try("input", function()
    hl.config({
        input = {
            kb_layout = "us,ara",
            kb_options = "grp:alt_shift_toggle",
            follow_mouse = 1,
            sensitivity = 0,
            touchpad = { natural_scroll = true },
        },
    })
end)

-- ── الاختصارات ──
local mod = "SUPER"

B(mod .. " + Return", X(terminal))
B(mod .. " + B",      X(browser))
B(mod .. " + E",      X(files))
B(mod .. " + Space",  X(menu))
B(mod .. " + Z",      X("zool-menu"))
B(mod .. " + L",      X("hyprlock"))
B(mod .. " + Escape", X("zool-power"))
B(mod .. " + F1",     X("zool-keys"))
B(mod .. " + SHIFT + W", X("zool-wallpaper pick"))
B(mod .. " + C",      X("sh -c 'cliphist list | wofi --dmenu | cliphist decode | wl-copy'"))
B("Print",            X("zool-screenshot region"))
B("SHIFT + Print",    X("zool-screenshot full"))

B(mod .. " + W", function() return hl.dsp.window.close() end)
B(mod .. " + F", function() return hl.dsp.window.fullscreen() end)
B(mod .. " + V", function() return hl.dsp.window.float({ action = "toggle" }) end)
B(mod .. " + P", function() return hl.dsp.window.pseudo() end)
B(mod .. " + J", function() return hl.dsp.layout("togglesplit") end)
B(mod .. " + SHIFT + M", X("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- التنقل بين النوافذ
for _, d in ipairs({ "left", "right", "up", "down" }) do
    B(mod .. " + " .. d,            function() return hl.dsp.focus({ direction = d }) end)
    B(mod .. " + SHIFT + " .. d,    function() return hl.dsp.window.move({ direction = d }) end)
end

-- مساحات العمل 1..9
for i = 1, 9 do
    B(mod .. " + " .. i,            function() return hl.dsp.focus({ workspace = i }) end)
    B(mod .. " + SHIFT + " .. i,    function() return hl.dsp.window.move({ workspace = i }) end)
end
B(mod .. " + mouse_down", function() return hl.dsp.focus({ workspace = "e+1" }) end)
B(mod .. " + mouse_up",   function() return hl.dsp.focus({ workspace = "e-1" }) end)

-- تحريك/تغيير حجم النوافذ بالفأرة
B(mod .. " + mouse:272", function() return hl.dsp.window.drag() end,   { mouse = true })
B(mod .. " + mouse:273", function() return hl.dsp.window.resize() end, { mouse = true })

-- الصوت والسطوع والوسائط
B("XF86AudioRaiseVolume", X("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
B("XF86AudioLowerVolume", X("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
B("XF86AudioMute",        X("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
B("XF86MonBrightnessUp",  X("brightnessctl set 5%+"),                          { locked = true, repeating = true })
B("XF86MonBrightnessDown",X("brightnessctl set 5%-"),                          { locked = true, repeating = true })
B("XF86AudioPlay",        X("playerctl play-pause"),                           { locked = true })
B("XF86AudioNext",        X("playerctl next"),                                 { locked = true })
B("XF86AudioPrev",        X("playerctl previous"),                             { locked = true })
