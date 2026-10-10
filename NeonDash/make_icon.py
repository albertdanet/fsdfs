import os
import struct
import sys
import zlib


def pixel(x, y, n):
    t = y / n
    r, g, b = int(10 + 40 * t), int(8 + 10 * t), int(40 + 90 * t)
    ground = n * 0.74
    if y > ground:
        r, g, b = 7, 7, 26
    if abs(y - ground) <= max(1, n // 60):
        r, g, b = 0, 229, 255

    # кубик
    s = n * 0.30
    cx, cy = n * 0.36, ground - s / 2
    dx, dy = abs(x - cx), abs(y - cy)
    if dx < s / 2 and dy < s / 2:
        r, g, b = 0, 229, 255
        if dx < s / 4 and dy < s / 4:
            r, g, b = 0, 20, 40
    else:
        d = max(dx - s / 2, dy - s / 2)
        glow = n * 0.06
        if 0 < d < glow:
            k = (1 - d / glow) ** 2 * 0.6
            r, g, b = int(r + (0 - r) * k), int(g + (229 - g) * k), int(b + (255 - b) * k)

    # шип
    sx = (x - n * 0.74) / (n * 0.09)
    h = n * 0.24
    if abs(sx) < 1 and y <= ground and y > ground - h * (1 - abs(sx)):
        r, g, b = 255, 45, 85

    return max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b))


def write_png(path, n):
    raw = bytearray()
    for y in range(n):
        raw.append(0)
        for x in range(n):
            raw.extend(pixel(x, y, n))

    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", n, n, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    write_png(os.path.join(out, "AppIcon60x60@2x.png"), 120)
    write_png(os.path.join(out, "AppIcon60x60@3x.png"), 180)
    print("icons written to", out)
