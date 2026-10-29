"""Zool OS — shared helpers: palette, text→SVG paths (font-independent), SVG→PNG rendering."""
import os
import uharfbuzz as hb
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen

# ── لوحة ألوان زول (سودانية ناعمة) ──────────────────────────
PALETTE = {
    "night":      "#10181c",   # ليل النيل (خلفية)
    "surface":    "#172229",
    "surface2":   "#213039",
    "sand":       "#f3e6cc",   # رمل (نص)
    "sand_dim":   "#b9a98a",
    "gold":       "#e8b04a",   # شمس الصحراء (لون التمييز)
    "terracotta": "#d46a43",   # طوب مروي
    "nile_blue":  "#2d86b4",   # النيل الأزرق
    "teal":       "#3ba5a0",   # التقاء النيلين
    "acacia":     "#8fb35f",   # الهجليج
    "rose":       "#e58b8b",
}

HERE = os.path.dirname(os.path.abspath(__file__))
FONT_DIR = os.environ.get("ZOOL_FONT_DIR", os.path.join(HERE, ".fonts"))


def font_ttf(woff_path):
    """يحوّل ملف woff إلى ttf (HarfBuzz لا يقرأ woff) ويخزّنه مؤقتاً."""
    os.makedirs(FONT_DIR, exist_ok=True)
    out = os.path.join(FONT_DIR, os.path.basename(woff_path).rsplit(".", 1)[0] + ".ttf")
    if not os.path.exists(out):
        f = TTFont(woff_path)
        f.flavor = None
        f.save(out)
    return out


def text_path(font_path, text, size, tracking=0.0):
    """نص → مسار SVG (d, العرض). خط الأساس عند y=0 والاتجاه للأعلى سالب."""
    blob = hb.Blob.from_file_path(font_path)
    font = hb.Font(hb.Face(blob))
    buf = hb.Buffer()
    buf.add_str(text)
    buf.guess_segment_properties()
    hb.shape(font, buf, {"kern": True, "liga": True, "calt": True})
    tt = TTFont(font_path)
    gs = tt.getGlyphSet()
    order = tt.getGlyphOrder()
    scale = size / tt["head"].unitsPerEm
    x = 0.0
    parts = []
    for info, pos in zip(buf.glyph_infos, buf.glyph_positions):
        pen = SVGPathPen(gs)
        tp = TransformPen(pen, (scale, 0, 0, -scale, (x + pos.x_offset) * scale, -pos.y_offset * scale))
        gs[order[info.codepoint]].draw(tp)
        parts.append(pen.getCommands())
        x += pos.x_advance + tracking / scale
    return " ".join(p for p in parts if p), x * scale


def render_svg(svg_text, out_path, width, height, scale=1.0, transparent=True, fmt=None, quality=92):
    """يحوّل SVG إلى PNG/JPEG عبر Chromium (Playwright)."""
    from playwright.sync_api import sync_playwright
    html = ("<html><body style='margin:0;background:%s'>%s</body></html>"
            % ("transparent" if transparent else "#000", svg_text))
    fmt = fmt or ("jpeg" if out_path.lower().endswith((".jpg", ".jpeg")) else "png")
    with sync_playwright() as p:
        b = p.chromium.launch()
        pg = b.new_page(viewport={"width": int(width), "height": int(height)}, device_scale_factor=scale)
        pg.set_content(html)
        pg.wait_for_timeout(200)
        kw = {"path": out_path, "type": fmt, "omit_background": transparent and fmt == "png"}
        if fmt == "jpeg":
            kw["quality"] = quality
        pg.screenshot(**kw)
        b.close()
