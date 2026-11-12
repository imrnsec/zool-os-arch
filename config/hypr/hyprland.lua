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
local terminal = "zool-terminal"
local files    = "thunar"
local browser  = "firefox"
local menu     = "wofi --show drun"

-- ── ألوان الثيم الحالي (يكتبها zool-theme في ~/.config/zool/theme/hypr) ──
local gold       = "rgba(e8b04aff)"
local terracotta = "rgba(d46a43ff)"
local inactive   = "rgba(213039aa)"
pcall(function()
    local f = io.open((os.getenv("HOME") or "") .. "/.config/zool/theme/hypr", "r")
    if not f then return end
    for line in f:lines() do
        local k, v = line:match("^(%w+)=(%x%x%x%x%x%x)%s*$")
        if k == "active1" then gold = "rgba(" .. v .. "ff)"
        elseif k == "active2" then terracotta = "rgba(" .. v .. "ff)"
        elseif k == "inactive" then inactive = "rgba(" .. v .. "aa)" end
    end
    f:close()
end)

-- ── الشاشة ──
try("monitor", function()
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
end)

-- ── البرامج التي تبدأ مع الجلسة (أولاً، حتى تعمل مهما حدث بعدها) ──
hl.on("hyprland.start", function()
    for _, cmd in ipairs({
        "sh -c '[ -e \"$HOME/.config/zool/lock-on-start\" ] && hyprlock'",   -- كلمة المرور عند بدء التشغيل
        "zool-wallpaper",
        "waybar",
        "mako",
        "zool-prayer daemon",
        "hypridle",
        "zool-battery-monitor",
        "zool-nightlight restore",
        "zool-welcome --auto",
        "sh -c 'sleep 120; zool-update notify'",
        "nm-applet --indicator",
        "zool-blueman-launch",
        "systemctl --user start hyprpolkitagent",
        "wl-paste --watch cliphist store",
        "sh -c 'sleep 4; notify-send -i /usr/share/zool/logo/zool-logo-128.png \"مرحباً بك في زول\" \"اضغط SUPER + F1 لعرض الاختصارات\"'",
    }) do
        try("autostart " .. cmd, function() hl.exec_cmd(cmd) end)
    end
end)

-- ── لغة الواجهة (zool-language): العربية تجعل البرامج كلها من اليمين لليسار ──
pcall(function()
    local f = io.open((os.getenv("HOME") or "") .. "/.config/zool/lang", "r")
    if not f then return end
    local v = (f:read("*l") or ""):gsub("%s+", "")
    f:close()
    if v == "ar" then
        hl.env("LANG", "ar_SD.UTF-8"); hl.env("LANGUAGE", "ar")
    elseif v == "en" then
        hl.env("LANG", "en_US.UTF-8"); hl.env("LANGUAGE", "en")
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

-- ── وضع المؤثرات: light (الافتراضي، للأجهزة الضعيفة) أو full ──
--    يُبدَّل من قائمة زول أو بالأمر:  zool-effects toggle
local effects = "light"
pcall(function()
    local home = os.getenv("HOME") or ""
    local f = io.open(home .. "/.config/zool/effects", "r")
    if f then
        local v = (f:read("*l") or ""):gsub("%s+", "")
        f:close()
        if v == "full" or v == "light" then effects = v end
    end
end)
local full = (effects == "full")

-- ── المظهر الناعم ──
try("general+decoration", function()
    hl.config({
        general = {
            gaps_in = full and 6 or 4,
            gaps_out = full and 14 or 8,
            border_size = 2,
            layout = "dwindle",
            resize_on_border = true,
            col = {
                active_border   = { colors = { gold, terracotta }, angle = 45 },
                inactive_border = inactive,
            },
        },
        decoration = {
            rounding = full and 14 or 10,
            active_opacity = 1.0,
            inactive_opacity = full and 0.93 or 1.0,
            blur = { enabled = full, size = 8, passes = 3, noise = 0.02, brightness = 1.0 },
            shadow = { enabled = full, range = 18, render_power = 3, color = "rgba(00000099)" },
        },
        animations = { enabled = true },
    })
end)

try("animations", function()
    hl.curve("soft",     { type = "bezier", points = { { 0.22, 1 },   { 0.36, 1 } } })
    hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
    if full then
        hl.animation({ leaf = "windows",    enabled = true, speed = 6,  bezier = "overshot", style = "slide" })
        hl.animation({ leaf = "windowsOut", enabled = true, speed = 5,  bezier = "soft",     style = "slide" })
        hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
        hl.animation({ leaf = "fade",       enabled = true, speed = 6,  bezier = "soft" })
        hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "soft",     style = "slidefade" })
    else
        -- حركات قصيرة وبسيطة: تبقى الواجهة حيّة دون إجهاد كرت الشاشة
        hl.animation({ leaf = "windows",    enabled = true, speed = 3,  bezier = "soft", style = "popin" })
        hl.animation({ leaf = "windowsOut", enabled = true, speed = 3,  bezier = "soft", style = "popin" })
        hl.animation({ leaf = "border",     enabled = false })
        hl.animation({ leaf = "fade",       enabled = true, speed = 3,  bezier = "soft" })
        hl.animation({ leaf = "workspaces", enabled = true, speed = 4,  bezier = "soft", style = "slide" })
    end
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

-- ── إيماءات لوحة اللمس: ٣ أصابع يميناً/يساراً = مساحة العمل التالية/السابقة، وللأسفل = قائمة زول ──
try("gestures", function()
    hl.gesture({ fingers = 3, direction = "left",  action = function() hl.dispatch(hl.dsp.focus({ workspace = "r-1" })) end })
    hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ workspace = "r+1" })) end })
    hl.gesture({ fingers = 3, direction = "down",  action = function() hl.dispatch(hl.dsp.exec_cmd("zool-menu")) end })
end)

-- ── الاختصارات ──
local mod = "SUPER"

B(mod .. " + Return", X(terminal))
B(mod .. " + ALT + Return", X("kitty"))      -- طرفية احتياطية
B(mod .. " + B",      X(browser))
B(mod .. " + E",      X(files))
B(mod .. " + Space",  X(menu))
B(mod .. " + Z",      X("zool-menu"))
B(mod .. " + ALT + Space",  X("zool-menu"))            -- كما في Omarchy
B(mod .. " + CTRL + Space", X("zool-wallpaper next"))  -- الخلفية التالية
B(mod .. " + L",      X("hyprlock"))
B(mod .. " + Escape", X("zool-power"))
B(mod .. " + F1",     X("zool-keys"))
B(mod .. " + SHIFT + W", X("zool-wallpaper pick"))
B(mod .. " + C",      X("sh -c 'cliphist list | wofi --dmenu | cliphist decode | wl-copy'"))
B("Print",            X("zool-screenshot region"))
B("SHIFT + Print",    X("zool-screenshot full"))

B(mod .. " + W", function() return hl.dsp.window.close() end)
B(mod .. " + Q", function() return hl.dsp.window.close() end)
B("ALT + F4",    function() return hl.dsp.window.close() end)   -- المألوف من ويندوز
B(mod .. " + SHIFT + E", X("zool-effects toggle"))
B(mod .. " + T",         X("zool-theme"))
B(mod .. " + N",         X("zool-nightlight toggle"))
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

-- الصوت والسطوع (مع مؤشر على الشاشة عبر zool-osd) والوسائط
B("XF86AudioRaiseVolume", X("zool-osd volume up"),     { locked = true, repeating = true })
B("XF86AudioLowerVolume", X("zool-osd volume down"),   { locked = true, repeating = true })
B("XF86AudioMute",        X("zool-osd volume mute"),   { locked = true })
B("XF86AudioMicMute",     X("zool-osd mic mute"),      { locked = true })
B("XF86MonBrightnessUp",  X("zool-osd brightness up"),   { locked = true, repeating = true })
B("XF86MonBrightnessDown",X("zool-osd brightness down"), { locked = true, repeating = true })
B("XF86AudioPlay",        X("playerctl play-pause"),                           { locked = true })
B("XF86AudioNext",        X("playerctl next"),                                 { locked = true })
B("XF86AudioPrev",        X("playerctl previous"),                             { locked = true })
