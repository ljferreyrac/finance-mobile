"""One-off generator for the Solvi app icon.

Draws everything with Pillow at 4x supersampling for clean anti-aliased
edges, then downsamples. Produces:
  - icon.png             1024x1024, navy background, full icon (iOS / legacy Android)
  - icon_foreground.png  1024x1024, transparent bg, mark only, sized to
                          Android's adaptive-icon safe zone (~66% of canvas)

Not part of the app build; run manually when the icon needs to change.
"""

from PIL import Image, ImageDraw

NAVY_900 = (11, 31, 58, 255)      # #0B1F3A
TEAL_400 = (29, 158, 117, 255)    # #1D9E75
TEAL_200 = (125, 207, 196, 255)   # #7DCFC4
WHITE = (255, 255, 255, 255)

SCALE = 4
SIZE = 1024 * SCALE


def draw_wallet_mark(draw, cx, cy, scale):
    """A simple rounded wallet body with a flap and a coin/clasp dot,
    plus a small spark for the AI angle. All coordinates relative to
    (cx, cy) and sized by `scale` (roughly the mark's half-width)."""

    body_w = scale * 2.0
    body_h = scale * 1.5
    left = cx - body_w / 2
    top = cy - body_h / 2 + scale * 0.15
    right = cx + body_w / 2
    bottom = cy + body_h / 2 + scale * 0.15

    # Wallet body.
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
    clasp_cy = cy + scale * 0.15
    draw.ellipse(
        [clasp_cx - clasp_r, clasp_cy - clasp_r, clasp_cx + clasp_r, clasp_cy + clasp_r],
        fill=NAVY_900,
    )

    # Spark (four-point star) above the top-right corner, for the AI angle.
    spark_cx = right - scale * 0.05
    spark_cy = top - flap_h * 0.9
    _draw_spark(draw, spark_cx, spark_cy, scale * 0.55, TEAL_200)


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
    """Draws the wallet+spark mark on its own transparent layer, then
    re-centers it on that layer's actual bounding box. The flap and spark
    are not symmetric around the draw origin, so centering on geometry
    (rather than the nominal cx/cy passed to draw_wallet_mark) is what
    keeps it inside Android's adaptive-icon safe circle."""
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw_wallet_mark(draw, SIZE / 2, SIZE / 2, mark_scale)
    bbox = layer.getbbox()
    bcx = (bbox[0] + bbox[2]) / 2
    bcy = (bbox[1] + bbox[3]) / 2
    dx = round(SIZE / 2 - bcx)
    dy = round(SIZE / 2 - bcy)
    centered = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    centered.paste(layer, (dx, dy), layer)
    return centered


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
    return _mark_layer(SIZE * 0.155)


def downsample_save(img, path, size=1024):
    img.resize((size, size), Image.LANCZOS).save(path)


if __name__ == "__main__":
    import os

    out_dir = os.path.dirname(os.path.abspath(__file__))
    downsample_save(build_full_icon(), os.path.join(out_dir, "icon.png"))
    downsample_save(build_foreground(), os.path.join(out_dir, "icon_foreground.png"))
    print("wrote icon.png and icon_foreground.png")
