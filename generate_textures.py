#!/usr/bin/env python3
"""Generate all textures for the Lazarus Space mod.

Requires Pillow: pip install Pillow

Produces 5 device textures (16x16) and 3 animated textures (16x128, 8 frames).
"""

import os
import random
from PIL import Image

TEXTURES_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "textures")
os.makedirs(TEXTURES_DIR, exist_ok=True)
random.seed(42)


def clamp(v):
    return max(0, min(255, int(v)))


# ---- Device textures (16x16) ----

def generate_disrupter_top():
    img = Image.new("RGBA", (16, 16))
    for y in range(16):
        for x in range(16):
            r, g, b = 40, 42, 48
            if x % 4 == 0 or y % 4 == 0:
                r -= 8; g -= 8; b -= 8
            if (x in (2, 3, 12, 13)) and (y in (2, 3, 12, 13)):
                r -= 12; g -= 10; b -= 6
            dx, dy = abs(x - 7.5), abs(y - 7.5)
            if dx < 2 and dy < 2:
                r += 12; g += 15; b += 25
            n = random.randint(-4, 4)
            img.putpixel((x, y), (clamp(r+n), clamp(g+n), clamp(b+n), 255))
    return img


def generate_disrupter_bottom():
    img = Image.new("RGBA", (16, 16))
    for y in range(16):
        for x in range(16):
            r, g, b = 30, 32, 36
            if x == 0 or x == 15 or y == 0 or y == 15:
                r -= 8; g -= 8; b -= 8
            dx = x - 7.5; dy = y - 7.5
            dist = (dx*dx + dy*dy) ** 0.5
            if dist < 3:
                r += 18; g += 12; b += 6
            elif dist < 4:
                r -= 6; g -= 6; b -= 6
            n = random.randint(-3, 3)
            img.putpixel((x, y), (clamp(r+n), clamp(g+n), clamp(b+n), 255))
    return img


def generate_disrupter_side():
    img = Image.new("RGBA", (16, 16))
    for y in range(16):
        for x in range(16):
            r, g, b = 45, 47, 54
            if y == 0 or y == 15:
                r -= 12; g -= 12; b -= 12
            if x == 5 or x == 10:
                r -= 10; g -= 10; b -= 10
            if y == 8:
                r -= 5; g -= 5; b -= 5
            n = random.randint(-3, 3)
            img.putpixel((x, y), (clamp(r+n), clamp(g+n), clamp(b+n), 255))
    return img


def generate_disrupter_front():
    img = Image.new("RGBA", (16, 16))
    for y in range(16):
        for x in range(16):
            r, g, b = 45, 47, 54
            if x == 0 or x == 15 or y == 0 or y == 15:
                r -= 12; g -= 12; b -= 12
            if 3 <= x <= 12 and 2 <= y <= 6:
                r, g, b = 22, 24, 28
                if y == 3 or y == 5:
                    r += 4; g += 4; b += 6
            dx = x - 7.5; dy = y - 10.5
            if dx*dx + dy*dy < 4:
                r, g, b = 26, 28, 30
            if 3 <= x <= 12 and 13 <= y <= 14:
                r -= 6; g -= 6; b -= 4
            n = random.randint(-2, 2)
            img.putpixel((x, y), (clamp(r+n), clamp(g+n), clamp(b+n), 255))
    return img


def generate_disrupter_front_active():
    img = Image.new("RGBA", (16, 16))
    for y in range(16):
        for x in range(16):
            r, g, b = 45, 47, 54
            if x == 0 or x == 15 or y == 0 or y == 15:
                r -= 12; g -= 12; b -= 12
            if 3 <= x <= 12 and 2 <= y <= 6:
                r, g, b = 18, 70, 110
                if y == 3 or y == 5:
                    r += 12; g += 35; b += 45
                cx = abs(x - 7.5)
                if cx < 3:
                    r += 8; g += 18; b += 25
            dx = x - 7.5; dy = y - 10.5
            dist = (dx*dx + dy*dy) ** 0.5
            if dist < 2:
                r, g, b = 45, 190, 230
            elif dist < 3:
                r, g, b = 25, 110, 150
            if 3 <= x <= 12 and 13 <= y <= 14:
                g += 8; b += 12
            cx2 = abs(x - 7.5); cy2 = abs(y - 7.5)
            gd = (cx2*cx2 + cy2*cy2) ** 0.5
            if gd < 7:
                glow = int((7 - gd) * 1.2)
                g += glow; b += int(glow * 1.4)
            n = random.randint(-2, 2)
            img.putpixel((x, y), (clamp(r+n), clamp(g+n), clamp(b+n), 255))
    return img


# ---- Animated textures (16x128, 8 frames) ----

def generate_disrupted_space():
    """Dark starfield void, 8 frames with slow star drift."""
    img = Image.new("RGBA", (16, 128))
    # Generate base star positions, shift slightly per frame.
    stars = [(random.randint(0, 15), random.randint(0, 15),
              random.randint(180, 255),
              random.choice([(255, 255, 255), (180, 200, 255), (200, 220, 255)]))
             for _ in range(12)]

    for frame in range(8):
        y_off = frame * 16
        # Black base.
        for y in range(16):
            for x in range(16):
                r, g, b = 2, 2, 5
                n = random.randint(0, 3)
                img.putpixel((x, y_off + y), (r + n, g + n, b + n, 255))
        # Stars with slight drift per frame.
        for sx, sy, brightness, color in stars:
            fx = (sx + frame // 3) % 16
            fy = (sy + frame // 4) % 16
            cr = int(color[0] * brightness / 255)
            cg = int(color[1] * brightness / 255)
            cb = int(color[2] * brightness / 255)
            img.putpixel((fx, y_off + fy), (cr, cg, cb, 255))
        # A few dim background stars.
        for _ in range(5):
            bx = random.randint(0, 15)
            by = random.randint(0, 15)
            bv = random.randint(30, 80)
            img.putpixel((bx, y_off + by), (bv, bv, bv + 10, 255))
    return img


def generate_decaying_uranium():
    """Bright yellow-green crackling energy, 8 frames."""
    img = Image.new("RGBA", (16, 128))

    for frame in range(8):
        y_off = frame * 16
        for y in range(16):
            for x in range(16):
                # Bright yellow-green base.
                r = random.randint(200, 255)
                g = random.randint(220, 255)
                b = random.randint(20, 80)
                # Energy crackling pattern.
                if random.random() < 0.15:
                    r = 255; g = 255; b = random.randint(180, 255)
                if random.random() < 0.08:
                    r = random.randint(100, 180)
                    g = random.randint(200, 255)
                    b = random.randint(0, 40)
                img.putpixel((x, y_off + y), (clamp(r), clamp(g), clamp(b), 255))
    return img


def generate_lazarus_portal():
    """Pure black void — solid 16x16, no animation."""
    img = Image.new("RGBA", (16, 16))
    for y in range(16):
        for x in range(16):
            img.putpixel((x, y), (0, 0, 0, 255))
    return img


def generate_star_near():
    """Bright white star dot with soft falloff, 8x8."""
    img = Image.new("RGBA", (8, 8))
    cx, cy = 3.5, 3.5
    for y in range(8):
        for x in range(8):
            dx, dy = x - cx, y - cy
            dist = (dx * dx + dy * dy) ** 0.5
            if dist < 1.0:
                alpha, bri = 255, 255
            elif dist < 3.5:
                t = (dist - 1.0) / 2.5
                alpha = int(255 * (1 - t))
                bri = int(255 * (1 - t * 0.3))
            else:
                alpha, bri = 0, 0
            img.putpixel((x, y), (bri, bri, min(255, bri + 10), alpha))
    return img


def generate_star_far():
    """Dimmer blue-tinted star dot, 8x8."""
    img = Image.new("RGBA", (8, 8))
    cx, cy = 3.5, 3.5
    for y in range(8):
        for x in range(8):
            dx, dy = x - cx, y - cy
            dist = (dx * dx + dy * dy) ** 0.5
            if dist < 1.2:
                alpha, bri = 160, 200
            elif dist < 3.5:
                t = (dist - 1.2) / 2.3
                alpha = int(160 * (1 - t))
                bri = int(200 * (1 - t * 0.4))
            else:
                alpha, bri = 0, 0
            img.putpixel((x, y), (int(bri * 0.85), int(bri * 0.9), bri, alpha))
    return img


def generate_star_nebula():
    """Pale purple/blue nebula glow, 8x8."""
    img = Image.new("RGBA", (8, 8))
    cx, cy = 3.5, 3.5
    for y in range(8):
        for x in range(8):
            dx, dy = x - cx, y - cy
            dist = (dx * dx + dy * dy) ** 0.5
            if dist < 1.5:
                alpha = 100
            elif dist < 4.0:
                alpha = int(100 * (1 - (dist - 1.5) / 2.5))
            else:
                alpha = 0
            img.putpixel((x, y), (120, 80, 180, alpha))
    return img


def generate_disrupted_space_variants():
    """Generate 20 opacity variants of the disrupted space texture.

    Variant 1 = most opaque, variant 20 = most transparent.
    Variants 1-10 (dense patches) have boosted alpha for
    darker, more defined patches. Variants 11-20 (transparent
    areas) are unchanged — near-invisible as intended.
    """
    base = generate_disrupted_space()
    variants = {}
    for i in range(1, 21):
        # Base alpha from 90 (variant 1) to 10 (variant 20)
        alpha = int(90 - (i - 1) * (90 - 10) / 19)
        # Boost variants 1-10 by 20-40% (more boost on denser)
        if i <= 10:
            # Variant 1 gets ~40% boost, variant 10 gets ~20%
            boost = 1.4 - (i - 1) * 0.02
            alpha = min(255, int(alpha * boost))
        img = base.copy()
        # Apply uniform alpha to all pixels.
        r, g, b, _ = img.split()
        a = Image.new("L", img.size, alpha)
        img = Image.merge("RGBA", (r, g, b, a))
        variants[f"lazarus_space_disrupted_space_{i}.png"] = img
    return variants


def main():
    textures = {
        "lazarus_space_disrupter_top.png": generate_disrupter_top(),
        "lazarus_space_disrupter_bottom.png": generate_disrupter_bottom(),
        "lazarus_space_disrupter_side.png": generate_disrupter_side(),
        "lazarus_space_disrupter_front.png": generate_disrupter_front(),
        "lazarus_space_disrupter_front_active.png": generate_disrupter_front_active(),
        "lazarus_space_disrupted_space.png": generate_disrupted_space(),
        "lazarus_space_decaying_uranium.png": generate_decaying_uranium(),
        "lazarus_space_lazarus_portal.png": generate_lazarus_portal(),
        "lazarus_space_star_near.png": generate_star_near(),
        "lazarus_space_star_far.png": generate_star_far(),
        "lazarus_space_star_nebula.png": generate_star_nebula(),
    }

    # Add 20 disrupted space opacity variants.
    textures.update(generate_disrupted_space_variants())

    for name, img in textures.items():
        path = os.path.join(TEXTURES_DIR, name)
        img.save(path)
        w, h = img.size
        frames = h // 16
        if frames > 1:
            print(f"Generated {name} ({w}x{h}, {frames} frames)")
        else:
            print(f"Generated {name} ({w}x{h})")

    print(f"\nAll textures saved to {TEXTURES_DIR}")


if __name__ == "__main__":
    main()
