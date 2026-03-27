#!/usr/bin/env python3
"""
FluentWoW TGA Texture Asset Generator
Generates all 25 texture assets defined in .docs/TextureAssets.md

All textures are pure white (#FFFFFF) on transparent background,
32-bit RGBA TGA format, for runtime color-tinting via SetVertexColor().
"""

import os
import math
from PIL import Image, ImageDraw, ImageFilter

OUTPUT_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "FluentWoW", "Assets", "Textures"
)


def ensure_dir():
    os.makedirs(OUTPUT_DIR, exist_ok=True)


def save_tga(img: Image.Image, name: str):
    path = os.path.join(OUTPUT_DIR, name)
    img.save(path, format="TGA")
    print(f"  Created: {name} ({img.size[0]}x{img.size[1]})")


# ─── Helper: Rounded rectangle on a larger canvas for anti-aliasing ───

def draw_rounded_rect_fill(width, height, radius, supersample=4):
    """Draw a filled rounded rectangle with anti-aliasing via supersampling."""
    sw, sh = width * supersample, height * supersample
    sr = radius * supersample
    img = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, sw - 1, sh - 1], radius=sr, fill=(255, 255, 255, 255))
    return img.resize((width, height), Image.LANCZOS)


def draw_rounded_rect_border(width, height, radius, stroke_width=1.5, supersample=4):
    """Draw a rounded rectangle outline (border only) with anti-aliasing."""
    sw, sh = width * supersample, height * supersample
    sr = radius * supersample
    ss = stroke_width * supersample
    img = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Draw outer filled, then subtract inner filled to get border
    outer = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    outer_draw = ImageDraw.Draw(outer)
    outer_draw.rounded_rectangle([0, 0, sw - 1, sh - 1], radius=sr, fill=(255, 255, 255, 255))

    inner = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    inner_draw = ImageDraw.Draw(inner)
    inner_draw.rounded_rectangle(
        [ss, ss, sw - 1 - ss, sh - 1 - ss],
        radius=max(sr - ss, 0),
        fill=(255, 255, 255, 255)
    )  

    # Subtract inner from outer
    result = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    outer_data = outer.load()
    inner_data = inner.load()
    result_data = result.load()
    for y in range(sh):
        for x in range(sw):
            oa = outer_data[x, y][3]
            ia = inner_data[x, y][3]
            a = max(oa - ia, 0)
            if a > 0:
                result_data[x, y] = (255, 255, 255, a)

    return result.resize((width, height), Image.LANCZOS)


def draw_pill_fill(width, height, supersample=4):
    """Draw a filled pill/capsule shape."""
    radius = height // 2
    return draw_rounded_rect_fill(width, height, radius, supersample)


def draw_pill_border(width, height, stroke_width=1.5, supersample=4):
    """Draw a pill/capsule outline."""
    radius = height // 2
    return draw_rounded_rect_border(width, height, radius, stroke_width, supersample)


def draw_circle_fill(diameter, supersample=4):
    """Draw a filled circle."""
    sd = diameter * supersample
    img = Image.new("RGBA", (sd, sd), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse([0, 0, sd - 1, sd - 1], fill=(255, 255, 255, 255))
    return img.resize((diameter, diameter), Image.LANCZOS)


def draw_circle_ring(diameter, stroke_width=1.5, supersample=4):
    """Draw a circle outline (ring)."""
    sd = diameter * supersample
    ss = stroke_width * supersample
    outer = Image.new("RGBA", (sd, sd), (0, 0, 0, 0))
    outer_draw = ImageDraw.Draw(outer)
    outer_draw.ellipse([0, 0, sd - 1, sd - 1], fill=(255, 255, 255, 255))

    inner = Image.new("RGBA", (sd, sd), (0, 0, 0, 0))
    inner_draw = ImageDraw.Draw(inner)
    inner_draw.ellipse([ss, ss, sd - 1 - ss, sd - 1 - ss], fill=(255, 255, 255, 255))

    result = Image.new("RGBA", (sd, sd), (0, 0, 0, 0))
    outer_data = outer.load()
    inner_data = inner.load()
    result_data = result.load()
    for y in range(sd):
        for x in range(sd):
            oa = outer_data[x, y][3]
            ia = inner_data[x, y][3]
            a = max(oa - ia, 0)
            if a > 0:
                result_data[x, y] = (255, 255, 255, a)

    return result.resize((diameter, diameter), Image.LANCZOS)


# ─── Asset Generators ───

def gen_01_roundrect4_64():
    """#1: FWoW_RoundRect4_64x64.tga — Rounded Rectangle 4px radius fill"""
    img = draw_rounded_rect_fill(64, 64, 4)
    save_tga(img, "FWoW_RoundRect4_64x64.tga")


def gen_02_roundrect8_64():
    """#2: FWoW_RoundRect8_64x64.tga — Rounded Rectangle 8px radius fill"""
    img = draw_rounded_rect_fill(64, 64, 8)
    save_tga(img, "FWoW_RoundRect8_64x64.tga")


def gen_03_roundrect4_border():
    """#3: FWoW_RoundRect4_Border_64x64.tga — 4px radius border only"""
    img = draw_rounded_rect_border(64, 64, 4, stroke_width=1.0)
    save_tga(img, "FWoW_RoundRect4_Border_64x64.tga")


def gen_04_roundrect8_border():
    """#4: FWoW_RoundRect8_Border_64x64.tga — 8px radius border only"""
    img = draw_rounded_rect_border(64, 64, 8, stroke_width=1.0)
    save_tga(img, "FWoW_RoundRect8_Border_64x64.tga")


def gen_05_roundrect4_shadow():
    """#5: FWoW_RoundRect4_Shadow_96x96.tga — Drop shadow for 4px radius"""
    supersample = 4
    canvas_size = 96
    rect_size = 64
    sc = canvas_size * supersample
    sr = rect_size * supersample
    offset = (sc - sr) // 2

    # Create the shadow shape (filled rounded rect)
    shadow = Image.new("L", (sc, sc), 0)
    shadow_draw = ImageDraw.Draw(shadow)
    # Offset 2px down -> 2*supersample
    y_offset = 2 * supersample
    shadow_draw.rounded_rectangle(
        [offset, offset + y_offset, offset + sr - 1, offset + sr - 1 + y_offset],
        radius=4 * supersample,
        fill=76  # ~30% of 255
    )

    # Gaussian blur
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=8 * supersample))

    # Convert to RGBA (black with alpha = shadow intensity)
    img = Image.new("RGBA", (sc, sc), (0, 0, 0, 0))
    for y in range(sc):
        for x in range(sc):
            a = shadow.getpixel((x, y))
            if a > 0:
                img.putpixel((x, y), (0, 0, 0, a))

    img = img.resize((canvas_size, canvas_size), Image.LANCZOS)
    save_tga(img, "FWoW_RoundRect4_Shadow_96x96.tga")


def gen_06_roundrect8_shadow():
    """#6: FWoW_RoundRect8_Shadow_96x96.tga — Drop shadow for 8px radius"""
    supersample = 4
    canvas_size = 96
    rect_size = 64
    sc = canvas_size * supersample
    sr = rect_size * supersample
    offset = (sc - sr) // 2

    shadow = Image.new("L", (sc, sc), 0)
    shadow_draw = ImageDraw.Draw(shadow)
    y_offset = 3 * supersample
    shadow_draw.rounded_rectangle(
        [offset, offset + y_offset, offset + sr - 1, offset + sr - 1 + y_offset],
        radius=8 * supersample,
        fill=64  # ~25% of 255
    )

    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=10 * supersample))

    img = Image.new("RGBA", (sc, sc), (0, 0, 0, 0))
    for y in range(sc):
        for x in range(sc):
            a = shadow.getpixel((x, y))
            if a > 0:
                img.putpixel((x, y), (0, 0, 0, a))

    img = img.resize((canvas_size, canvas_size), Image.LANCZOS)
    save_tga(img, "FWoW_RoundRect8_Shadow_96x96.tga")


def gen_07_pill_44x20():
    """#7: FWoW_Pill_44x20.tga — Toggle Switch Track fill"""
    img = draw_pill_fill(44, 20)
    save_tga(img, "FWoW_Pill_44x20.tga")


def gen_08_pill_border_44x20():
    """#8: FWoW_Pill_Border_44x20.tga — Toggle Switch Track border"""
    img = draw_pill_border(44, 20, stroke_width=1.5)
    save_tga(img, "FWoW_Pill_Border_44x20.tga")


def gen_09_pilltrack_32x8():
    """#9: FWoW_PillTrack_32x8.tga — Slider/ProgressBar Track"""
    img = draw_pill_fill(32, 8)
    save_tga(img, "FWoW_PillTrack_32x8.tga")


def gen_10_pillfill_32x8():
    """#10: FWoW_PillFill_32x8.tga — Slider/ProgressBar Fill"""
    img = draw_pill_fill(32, 8)
    save_tga(img, "FWoW_PillFill_32x8.tga")


def gen_11_circle_20x20():
    """#11: FWoW_Circle_20x20.tga — Slider Thumb"""
    img = draw_circle_fill(20)
    save_tga(img, "FWoW_Circle_20x20.tga")


def gen_12_circle_14x14():
    """#12: FWoW_Circle_14x14.tga — Toggle Switch Thumb"""
    img = draw_circle_fill(14)
    save_tga(img, "FWoW_Circle_14x14.tga")


def gen_13_circle_shadow_24x24():
    """#13: FWoW_Circle_Shadow_24x24.tga — Thumb shadow"""
    supersample = 4
    diameter = 24
    inner_d = 14
    sd = diameter * supersample
    si = inner_d * supersample

    # Create shadow shape (circle slightly larger than 14px)
    shadow = Image.new("L", (sd, sd), 0)
    shadow_draw = ImageDraw.Draw(shadow)
    offset_inner = (sd - si) // 2
    # Offset 1px down
    y_off = 1 * supersample
    shadow_draw.ellipse(
        [offset_inner, offset_inner + y_off, offset_inner + si - 1, offset_inner + si - 1 + y_off],
        fill=51  # ~20% of 255
    )

    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=3 * supersample))

    img = Image.new("RGBA", (sd, sd), (0, 0, 0, 0))
    for y in range(sd):
        for x in range(sd):
            a = shadow.getpixel((x, y))
            if a > 0:
                img.putpixel((x, y), (0, 0, 0, a))

    img = img.resize((diameter, diameter), Image.LANCZOS)
    save_tga(img, "FWoW_Circle_Shadow_24x24.tga")


def gen_14_circlering_20x20():
    """#14: FWoW_CircleRing_20x20.tga — Radio Button Outer Ring"""
    img = draw_circle_ring(20, stroke_width=1.5)
    save_tga(img, "FWoW_CircleRing_20x20.tga")


def gen_15_circledot_10x10():
    """#15: FWoW_CircleDot_10x10.tga — Radio Button Inner Dot"""
    img = draw_circle_fill(10)
    save_tga(img, "FWoW_CircleDot_10x10.tga")


def gen_16_roundsquare_20x20():
    """#16: FWoW_RoundSquare_20x20.tga — CheckBox Unchecked outline"""
    img = draw_rounded_rect_border(20, 20, 3, stroke_width=1.5)
    save_tga(img, "FWoW_RoundSquare_20x20.tga")


def gen_17_roundsquare_filled_20x20():
    """#17: FWoW_RoundSquare_Filled_20x20.tga — CheckBox Checked fill"""
    img = draw_rounded_rect_fill(20, 20, 3)
    save_tga(img, "FWoW_RoundSquare_Filled_20x20.tga")


def gen_18_focusrect4_64x64():
    """#18: FWoW_FocusRect4_64x64.tga — Focus Ring 4px radius"""
    supersample = 4
    size = 64
    ss = size * supersample
    radius = 4 * supersample

    result = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))

    # Inner ring: 2px white
    inner_stroke = 2 * supersample
    inner_outer = Image.new("L", (ss, ss), 0)
    d = ImageDraw.Draw(inner_outer)
    d.rounded_rectangle([0, 0, ss - 1, ss - 1], radius=radius, fill=255)

    inner_inner = Image.new("L", (ss, ss), 0)
    d2 = ImageDraw.Draw(inner_inner)
    inset = inner_stroke
    d2.rounded_rectangle(
        [inset, inset, ss - 1 - inset, ss - 1 - inset],
        radius=max(radius - inset, 0),
        fill=255
    )

    # Outer ring: 1px black at 60% opacity, with 1px gap
    gap = 1 * supersample
    outer_stroke = 1 * supersample
    outer_outer_offset = inner_stroke + gap
    # Actually the outer ring is OUTSIDE the inner ring
    # So: outer ring outer edge = the canvas edge
    # outer ring inner edge = inner_stroke + gap from edge
    # Wait, the focus ring is: inner white ring close to the control, outer dark ring outside.
    # Let me reconsider: the inner ring is drawn at the boundary, outer ring is outside.
    # Per spec: "inner outline is 2px wide in white", "1px gap", "outer outline 1px wide in black at 60%"
    # So from outside-in: outer ring (1px) -> gap (1px) -> inner ring (2px) -> control
    # But we're drawing on a 64x64 canvas. Let's say the control boundary is inset by total ring width.
    # Total = 1 (outer) + 1 (gap) + 2 (inner) = 4px from edge

    total_inset = (outer_stroke + gap + inner_stroke)

    # Outer ring (outermost)
    outer_ring_outer = Image.new("L", (ss, ss), 0)
    d3 = ImageDraw.Draw(outer_ring_outer)
    d3.rounded_rectangle([0, 0, ss - 1, ss - 1], radius=radius, fill=255)

    outer_ring_inner = Image.new("L", (ss, ss), 0)
    d4 = ImageDraw.Draw(outer_ring_inner)
    d4.rounded_rectangle(
        [outer_stroke, outer_stroke, ss - 1 - outer_stroke, ss - 1 - outer_stroke],
        radius=max(radius - outer_stroke, 0),
        fill=255
    )

    # Inner ring (after gap)
    inner_ring_start = outer_stroke + gap
    inner_ring_outer_mask = Image.new("L", (ss, ss), 0)
    d5 = ImageDraw.Draw(inner_ring_outer_mask)
    d5.rounded_rectangle(
        [inner_ring_start, inner_ring_start, ss - 1 - inner_ring_start, ss - 1 - inner_ring_start],
        radius=max(radius - inner_ring_start, 0),
        fill=255
    )

    inner_ring_end = inner_ring_start + inner_stroke
    inner_ring_inner_mask = Image.new("L", (ss, ss), 0)
    d6 = ImageDraw.Draw(inner_ring_inner_mask)
    d6.rounded_rectangle(
        [inner_ring_end, inner_ring_end, ss - 1 - inner_ring_end, ss - 1 - inner_ring_end],
        radius=max(radius - inner_ring_end, 0),
        fill=255
    )

    # Composite
    result_data = result.load()
    oro = outer_ring_outer.load()
    ori = outer_ring_inner.load()
    iro = inner_ring_outer_mask.load()
    iri = inner_ring_inner_mask.load()

    for y in range(ss):
        for x in range(ss):
            # Outer ring: between outer_ring_outer and outer_ring_inner
            outer_a = max(oro[x, y] - ori[x, y], 0)
            # Inner ring: between inner_ring_outer_mask and inner_ring_inner_mask
            inner_a = max(iro[x, y] - iri[x, y], 0)

            if inner_a > 0:
                result_data[x, y] = (255, 255, 255, inner_a)
            elif outer_a > 0:
                result_data[x, y] = (0, 0, 0, int(outer_a * 0.6))

    result = result.resize((size, size), Image.LANCZOS)
    save_tga(result, "FWoW_FocusRect4_64x64.tga")


def gen_19_focusrect8_64x64():
    """#19: FWoW_FocusRect8_64x64.tga — Focus Ring 8px radius"""
    supersample = 4
    size = 64
    ss = size * supersample
    radius = 8 * supersample

    result = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))

    outer_stroke = 1 * supersample
    gap = 1 * supersample
    inner_stroke = 2 * supersample

    # Outer ring
    outer_ring_outer = Image.new("L", (ss, ss), 0)
    ImageDraw.Draw(outer_ring_outer).rounded_rectangle([0, 0, ss - 1, ss - 1], radius=radius, fill=255)

    outer_ring_inner = Image.new("L", (ss, ss), 0)
    ImageDraw.Draw(outer_ring_inner).rounded_rectangle(
        [outer_stroke, outer_stroke, ss - 1 - outer_stroke, ss - 1 - outer_stroke],
        radius=max(radius - outer_stroke, 0), fill=255
    )

    # Inner ring
    inner_ring_start = outer_stroke + gap
    inner_ring_outer_mask = Image.new("L", (ss, ss), 0)
    ImageDraw.Draw(inner_ring_outer_mask).rounded_rectangle(
        [inner_ring_start, inner_ring_start, ss - 1 - inner_ring_start, ss - 1 - inner_ring_start],
        radius=max(radius - inner_ring_start, 0), fill=255
    )

    inner_ring_end = inner_ring_start + inner_stroke
    inner_ring_inner_mask = Image.new("L", (ss, ss), 0)
    ImageDraw.Draw(inner_ring_inner_mask).rounded_rectangle(
        [inner_ring_end, inner_ring_end, ss - 1 - inner_ring_end, ss - 1 - inner_ring_end],
        radius=max(radius - inner_ring_end, 0), fill=255
    )

    result_data = result.load()
    oro = outer_ring_outer.load()
    ori = outer_ring_inner.load()
    iro = inner_ring_outer_mask.load()
    iri = inner_ring_inner_mask.load()

    for y in range(ss):
        for x in range(ss):
            outer_a = max(oro[x, y] - ori[x, y], 0)
            inner_a = max(iro[x, y] - iri[x, y], 0)
            if inner_a > 0:
                result_data[x, y] = (255, 255, 255, inner_a)
            elif outer_a > 0:
                result_data[x, y] = (0, 0, 0, int(outer_a * 0.6))

    result = result.resize((size, size), Image.LANCZOS)
    save_tga(result, "FWoW_FocusRect8_64x64.tga")


def gen_20_badge_pill():
    """#20: FWoW_Badge_Pill_48x20.tga — Badge Background pill"""
    img = draw_pill_fill(48, 20)
    save_tga(img, "FWoW_Badge_Pill_48x20.tga")


def gen_21_nav_indicator():
    """#21: FWoW_NavIndicator_3x16.tga — Vertical nav selection bar"""
    # Vertical pill: 3px wide, 16px tall, radius = 1.5px (half width)
    img = draw_pill_fill(3, 16, supersample=8)  # Higher supersample for tiny texture
    save_tga(img, "FWoW_NavIndicator_3x16.tga")


def gen_22_tab_indicator():
    """#22: FWoW_TabIndicator_32x3.tga — Horizontal tab selection bar"""
    # Horizontal pill: 32px wide, 3px tall, radius = 1.5px
    img = draw_pill_fill(32, 3, supersample=8)
    save_tga(img, "FWoW_TabIndicator_32x3.tga")


def gen_23_progress_ring():
    """#23: FWoW_ProgressRing_32x32.tga — Indeterminate spinner arc"""
    supersample = 4
    size = 32
    ss = size * supersample
    outer_r = 14 * supersample
    stroke = 2 * supersample
    inner_r = outer_r - stroke
    cx, cy = ss // 2, ss // 2

    img = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))
    pixels = img.load()

    # Draw a 270° arc from 12 o'clock (−90°) sweeping clockwise to 9 o'clock (180°)
    # With a tapered trailing end (fade-out over last 30°)
    start_angle = -90  # 12 o'clock
    sweep = 270
    end_angle = start_angle + sweep  # 180°
    taper_degrees = 30
    taper_start = end_angle - taper_degrees  # Start tapering 30° before end

    for y in range(ss):
        for x in range(ss):
            dx = x - cx
            dy = y - cy
            dist = math.sqrt(dx * dx + dy * dy)

            # Check if within ring band (with AA)
            if dist < inner_r - 1 or dist > outer_r + 1:
                continue

            # Radial AA
            if dist < inner_r:
                radial_aa = dist - (inner_r - 1)
            elif dist > outer_r:
                radial_aa = (outer_r + 1) - dist
            else:
                radial_aa = 1.0

            # Angle in degrees
            angle = math.degrees(math.atan2(dy, dx))
            # Normalize so start_angle maps to 0
            rel_angle = (angle - start_angle) % 360

            if rel_angle > sweep + 1:
                continue

            # Angular AA at edges
            if rel_angle > sweep:
                angular_aa = (sweep + 1) - rel_angle
            elif rel_angle < 1:
                angular_aa = rel_angle
            else:
                angular_aa = 1.0

            # Taper (trailing fade) — fade over last taper_degrees
            rel_end = sweep - rel_angle
            if rel_end < taper_degrees:
                # At rel_end=0 (the end), opacity = 0.2; at rel_end=taper_degrees, opacity = 1.0
                taper_factor = 0.2 + 0.8 * (rel_end / taper_degrees)
            else:
                taper_factor = 1.0

            alpha = int(255 * min(radial_aa, angular_aa) * taper_factor)
            if alpha > 0:
                pixels[x, y] = (255, 255, 255, min(alpha, 255))

    img = img.resize((size, size), Image.LANCZOS)
    save_tga(img, "FWoW_ProgressRing_32x32.tga")


def gen_24_arrow_up():
    """#24: FWoW_Arrow_Up_16x8.tga — TeachingTip callout arrow"""
    supersample = 4
    w, h = 16, 8
    sw, sh = w * supersample, h * supersample

    img = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Triangle: apex at top center, base at bottom
    draw.polygon([(sw // 2, 0), (0, sh - 1), (sw - 1, sh - 1)], fill=(255, 255, 255, 255))

    img = img.resize((w, h), Image.LANCZOS)
    save_tga(img, "FWoW_Arrow_Up_16x8.tga")


def gen_25_scroll_thumb():
    """#25: FWoW_ScrollThumb_8x32.tga — Scrollbar thumb vertical pill"""
    img = draw_pill_fill(8, 32)
    save_tga(img, "FWoW_ScrollThumb_8x32.tga")


def main():
    ensure_dir()
    print("FluentWoW TGA Texture Generator")
    print("=" * 40)
    print(f"Output: {OUTPUT_DIR}\n")

    generators = [
        gen_01_roundrect4_64,
        gen_02_roundrect8_64,
        gen_03_roundrect4_border,
        gen_04_roundrect8_border,
        gen_05_roundrect4_shadow,
        gen_06_roundrect8_shadow,
        gen_07_pill_44x20,
        gen_08_pill_border_44x20,
        gen_09_pilltrack_32x8,
        gen_10_pillfill_32x8,
        gen_11_circle_20x20,
        gen_12_circle_14x14,
        gen_13_circle_shadow_24x24,
        gen_14_circlering_20x20,
        gen_15_circledot_10x10,
        gen_16_roundsquare_20x20,
        gen_17_roundsquare_filled_20x20,
        gen_18_focusrect4_64x64,
        gen_19_focusrect8_64x64,
        gen_20_badge_pill,
        gen_21_nav_indicator,
        gen_22_tab_indicator,
        gen_23_progress_ring,
        gen_24_arrow_up,
        gen_25_scroll_thumb,
    ]

    for gen in generators:
        gen()

    print(f"\nDone! Generated {len(generators)} texture assets.")


if __name__ == "__main__":
    main()
