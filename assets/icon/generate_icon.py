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
    mark = _mark_layer(SIZE * 0.34)
    img.alpha_composite(mark)
    return img.convert("RGB")


def build_foreground():
    # Adaptive icons get center-cropped to a circle/squircle by the OS, so
    # keep the mark within the inner ~66% safe zone on a transparent canvas.
    # NOTE: mipmap-anydpi-v26/ic_launcher.xml also insets this drawable by
    # 16% (Android's official adaptive-icon safe-zone margin) before the OS
    # applies its own mask. That means the true safe radius in THIS image's
    # own coordinate space is ~45% of the canvas, not 33% - using 33% here
    # would double-apply the same margin and draw the mark unnecessarily
    # small. Verify with generate_icon.py's __main__ safe-zone check after
    # any change here.
    return _mark_layer(SIZE * 0.22)


def build_logo_mark():
    # Same mark, cropped tight instead of padded to an OS safe zone - this
    # one is for in-app display, not a launcher icon.
    #
    # Crucially, this crop stays centered on the CANVAS center (SIZE/2,
    # SIZE/2), which is where _mark_layer draws the wallet - not on the
    # wallet+spark combined content bbox. Centering on the combined bbox
    # (an earlier bug) pulls the crop toward the spark, since the spark
    # sticks out past the wallet on one side only; the wallet - the shape
    # people actually anchor on - then reads as off-center even though the
    # bbox math is "correct". Sizing the crop from the *maximum* distance
    # from canvas center to any content edge guarantees nothing is cut off
    # while preserving that centering.
    layer = _mark_layer(SIZE * 0.36)
    bbox = layer.getbbox()
    cx, cy = SIZE / 2, SIZE / 2
    half_side = max(cx - bbox[0], bbox[2] - cx, cy - bbox[1], bbox[3] - cy)
    half_side *= 1.06  # small breathing room
    return layer.crop((
        int(cx - half_side), int(cy - half_side),
        int(cx + half_side), int(cy + half_side),
    ))


def downsample_save(img, path, size=1024):
    img.resize((size, size), Image.LANCZOS).save(path)


def _check_foreground_safe_zone(fg_path, size=1024):
    """Prints the foreground mark's max distance from canvas center against
    the effective safe radius, accounting for the 16% inset applied in
    mipmap-anydpi-v26/ic_launcher.xml (see build_foreground's docstring)."""
    import math

    img = Image.open(fg_path)
    bbox = img.getbbox()
    cx, cy = size / 2, size / 2
    corners = [(bbox[0], bbox[1]), (bbox[2], bbox[1]), (bbox[0], bbox[3]), (bbox[2], bbox[3])]
    maxd = max(math.hypot(x - cx, y - cy) for x, y in corners)
    effective_safe_radius = (33 / (108 * 0.68)) * size
    status = "OK" if maxd <= effective_safe_radius else "TOO BIG - will clip on some launchers"
    print(f"  foreground safe-zone check: maxdist={maxd:.1f} vs "
          f"effective_safe_radius={effective_safe_radius:.1f}  [{status}]")


if __name__ == "__main__":
    import os

    out_dir = os.path.dirname(os.path.abspath(__file__))
    icon_path = os.path.join(out_dir, "icon.png")
    fg_path = os.path.join(out_dir, "icon_foreground.png")
    mark_path = os.path.join(out_dir, "logo_mark.png")
    downsample_save(build_full_icon(), icon_path)
    downsample_save(build_foreground(), fg_path)
    downsample_save(build_logo_mark(), mark_path)
    print("wrote icon.png, icon_foreground.png, and logo_mark.png")
    _check_foreground_safe_zone(fg_path)
