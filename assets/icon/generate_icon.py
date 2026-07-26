"""One-off generator for the Solvi app icon.

Draws everything with Pillow at 4x supersampling for clean anti-aliased
edges, then downsamples. Produces:
  - icon.png             1024x1024, navy background, full icon (iOS / legacy Android)
  - icon_foreground.png  1024x1024, transparent bg, mark only, sized to
                          Android's adaptive-icon safe zone (~66% of canvas)
  - logo_mark.png         1024x1024, transparent bg, mark tightly cropped
                          (no OS safe-zone padding) - for in-app use, e.g.
                          the login/register header, where a small padded
                          mark would render too small at typical icon sizes

The wallet is the centered, dominant shape; the spark is a corner accent
that is deliberately NOT part of the centering calculation (like a
notification badge - only the main glyph centers, the accent overlaps a
corner). Not part of the app build; run manually when the icon needs to
change.
"""

from PIL import Image, ImageDraw

NAVY_900 = (11, 31, 58, 255)      # #0B1F3A
TEAL_400 = (29, 158, 117, 255)    # #1D9E75
TEAL_200 = (125, 207, 196, 255)   # #7DCFC4

SCALE = 4
SIZE = 1024 * SCALE


def draw_wallet_body(draw, cx, cy, scale):
    """Rounded wallet body + flap + clasp dot, centered exactly at
    (cx, cy). Returns the (left, top, right, bottom) bbox of the body
    itself (not the flap), used both to center this shape and to anchor
    the spark accent relative to it."""

    body_w = scale * 2.0
    body_h = scale * 1.5
    left = cx - body_w / 2
    top = cy - body_h / 2
    right = cx + body_w / 2
    bottom = cy + body_h / 2

    draw.rounded_rectangle(
        [left, top, right, bottom],
        radius=scale * 0.28,
        fill=TEAL_400,
    )

    # Flap peeking above the body (gives it a "wallet", not "envelope", read).
    flap_h = scale * 0.5
    draw.rounded_rectangle(
        [left + scale * 0.15, top - flap_h * 0.55, right - scale * 0.15, top + flap_h * 0.45],
        radius=scale * 0.22,
        fill=TEAL_400,
    )

    # Clasp/coin dot on the body, in navy so it reads as a cutout.
    clasp_r = scale * 0.22
    clasp_cx = right - body_w * 0.28
    clasp_cy = cy
    draw.ellipse(
        [clasp_cx - clasp_r, clasp_cy - clasp_r, clasp_cx + clasp_r, clasp_cy + clasp_r],
        fill=NAVY_900,
    )

    return (left, top, right, bottom)


def draw_spark_accent(draw, body_bbox, scale):
    """Small sparkle overlapping the wallet's top-right corner. Anchored
    to the body's own bbox, not the canvas center - it is an accent, not
    part of what gets centered."""
    _, top, right, _ = body_bbox
    spark_cx = right - scale * 0.15
    spark_cy = top - scale * 0.05
    _draw_spark(draw, spark_cx, spark_cy, scale * 0.5, TEAL_200)


def _draw_spark(draw, cx, cy, r, fill):
    """Four-point sparkle: two overlapping stretched diamonds."""
    long_pts = [
        (cx, cy - r),
        (cx + r * 0.22, cy - r * 0.22),
        (cx + r, cy),
        (cx + r * 0.22, cy + r * 0.22),
        (cx, cy + r),
        (cx - r * 0.22, cy + r * 0.22),
        (cx - r, cy),
        (cx - r * 0.22, cy - r * 0.22),
    ]
    draw.polygon(long_pts, fill=fill)


def _mark_layer(mark_scale):
    """Draws the wallet centered exactly at the canvas center, then the
    spark accent anchored off the wallet's corner. Centering happens
    only on the wallet body, by construction (no post-hoc bbox
    recentering) - the spark is allowed to sit off-center like any
    corner badge."""
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    body_bbox = draw_wallet_body(draw, SIZE / 2, SIZE / 2, mark_scale)
    draw_spark_accent(draw, body_bbox, mark_scale)
    return layer


def build_full_icon():
    # Flat, fully opaque square: iOS applies its own corner mask and the App
    # Store rejects icons carrying an alpha channel, so no pre-rounding here.
    # Android's launcher_icons tool also derives its own rounded/circle/
    # legacy variants from this master.
    img = Image.new("RGBA", (SIZE, SIZE), NAVY_900)
    mark = _mark_layer(SIZE * 0.20)
    img.alpha_composite(mark)
    return img.convert("RGB")


def build_foreground():
    # Adaptive icons get center-cropped to a circle/squircle by the OS, so
    # keep the mark within the inner ~66% safe zone on a transparent canvas.
    return _mark_layer(SIZE * 0.145)


def build_logo_mark():
    # Same mark, drawn larger and then cropped tight to its own content
    # (plus a small margin) instead of padded to an OS safe zone - this
    # one is for in-app display, not a launcher icon.
    layer = _mark_layer(SIZE * 0.36)
    bbox = layer.getbbox()
    pad = int((bbox[2] - bbox[0]) * 0.08)
    left, top, right, bottom = bbox
    left -= pad
    top -= pad
    right += pad
    bottom += pad
    # Pad to a centered square canvas so the asset displays predictably
    # regardless of the wallet's own (wider-than-tall) aspect ratio.
    w, h = right - left, bottom - top
    side = max(w, h)
    cx, cy = (left + right) / 2, (top + bottom) / 2
    square = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    square.paste(layer, (0, 0), layer)
    return square.crop((
        int(cx - side / 2), int(cy - side / 2),
        int(cx + side / 2), int(cy + side / 2),
    ))


def downsample_save(img, path, size=1024):
    img.resize((size, size), Image.LANCZOS).save(path)


if __name__ == "__main__":
    import os

    out_dir = os.path.dirname(os.path.abspath(__file__))
    downsample_save(build_full_icon(), os.path.join(out_dir, "icon.png"))
    downsample_save(build_foreground(), os.path.join(out_dir, "icon_foreground.png"))
    downsample_save(build_logo_mark(), os.path.join(out_dir, "logo_mark.png"))
    print("wrote icon.png, icon_foreground.png, and logo_mark.png")
