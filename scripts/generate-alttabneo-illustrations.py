#!/usr/bin/env python3
"""
Genera las 22 ilustraciones HEIC de Appearance a partir de 3 PNG fuente:

  resources/illustrations/_source_thumbnails.png  ← ~/Downloads/thumbnails.png
  resources/illustrations/_source_app_icons.png   ← ~/Downloads/app icon.png
  resources/illustrations/_source_titles.png      ← ~/Downloads/titles.png

Variantes (iconos +, Space, círculos de acción, etiquetas) se dibujan encima.
"""
from __future__ import annotations

import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "resources" / "illustrations"
W, H = 1000, 625

SOURCE_FILES = {
    "thumbnails": OUT / "_source_thumbnails.png",
    "app_icons": OUT / "_source_app_icons.png",
    "titles": OUT / "_source_titles.png",
}

DOWNLOAD_FILES = {
    "thumbnails": Path.home() / "Downloads" / "thumbnails.png",
    "app_icons": Path.home() / "Downloads" / "app icon.png",
    "titles": Path.home() / "Downloads" / "titles.png",
}

PANELS: dict[str, Image.Image] = {}
BACKGROUND: Image.Image | None = None


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for path in (
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
    ):
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


def resolve_source(key: str) -> Path:
    primary = SOURCE_FILES[key]
    if primary.exists():
        return primary
    fallback = DOWNLOAD_FILES[key]
    if fallback.exists():
        return fallback
    raise FileNotFoundError(f"Falta imagen fuente para {key}: {primary} o {fallback}")


def sync_sources_from_downloads() -> None:
    """Copia desde Descargas si el usuario actualizó los PNG allí."""
    OUT.mkdir(parents=True, exist_ok=True)
    for key in SOURCE_FILES:
        src = DOWNLOAD_FILES[key]
        dst = SOURCE_FILES[key]
        if src.exists() and (not dst.exists() or src.stat().st_mtime > dst.stat().st_mtime):
            dst.write_bytes(src.read_bytes())


def load_panels() -> None:
    global PANELS, BACKGROUND
    sync_sources_from_downloads()
    for key in SOURCE_FILES:
        PANELS[key] = Image.open(resolve_source(key)).convert("RGB")
    # Fondo = color del borde de las fuentes (gris claro del mock)
    bg_color = PANELS["thumbnails"].getpixel((8, 8))
    BACKGROUND = Image.new("RGB", (W, H), bg_color)


def parse_name(name: str) -> dict:
    base = name.replace("@2x", "")
    if base.endswith("_light"):
        base = base[: -len("_light")]
    if base.startswith("app_icons"):
        style, rest = "app_icons", base[len("app_icons") :].lstrip("_")
    elif base.startswith("thumbnails"):
        style, rest = "thumbnails", base[len("thumbnails") :].lstrip("_")
    elif base.startswith("titles"):
        style, rest = "titles", base[len("titles") :].lstrip("_")
    else:
        style, rest = base.split("_")[0], ""
    return {
        "style": style,
        "show_status": "hide_status_icons" not in rest,
        "show_space": "hide_space_number_labels" not in rest,
        "show_circles": "show_colored_circles" in rest,
        "hide_circles": "hide_colored_circles" in rest,
        "label_mode": (
            "both"
            if "applications_windows" in rest
            else "windows"
            if "running_windows" in rest
            else "apps"
            if "running_applications" in rest
            else "none"
        ),
    }


def compose(panel: Image.Image) -> tuple[Image.Image, tuple[int, int, int, int]]:
    assert BACKGROUND is not None
    canvas = BACKGROUND.copy()
    pw, ph = panel.size
    max_w, max_h = int(W * 0.88), int(H * 0.88)
    scale = min(max_w / pw, max_h / ph)
    nw, nh = int(pw * scale), int(ph * scale)
    resized = panel.resize((nw, nh), Image.LANCZOS)
    x, y = (W - nw) // 2, (H - nh) // 2
    canvas.paste(resized, (x, y))
    return canvas, (x, y, nw, nh)


def draw_status_badges(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], show_status: bool, show_space: bool):
    x, y, w, h = box
    rx = x + w - 16
    ty = y + int(h * 0.04)
    if show_status:
        draw.ellipse((rx - 56, ty, rx - 28, ty + 28), outline=(90, 90, 95), width=2)
        draw.text((rx - 48, ty + 2), "+", fill=(90, 90, 95), font=font(18, bold=True))
    if show_space:
        draw.ellipse((rx - 26, ty, rx + 2, ty + 28), outline=(90, 90, 95), width=2)
        draw.text((rx - 18, ty + 4), "2", fill=(90, 90, 95), font=font(14, bold=True))


def draw_action_circles(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], show: bool, highlight: bool):
    if not show:
        return
    x, y, w, h = box
    cx0 = x + int(w * 0.1)
    cy0 = y + int(h * 0.22)
    colors = [(147, 51, 234), (239, 68, 68), (234, 179, 8), (34, 197, 94)]
    for i, col in enumerate(colors):
        cx = cx0 + i * 32
        if highlight:
            draw.ellipse((cx - 16, cy0 - 16, cx + 16, cy0 + 16), outline=(239, 68, 68), width=3)
        draw.ellipse((cx - 12, cy0 - 12, cx + 12, cy0 + 12), fill=col)


def draw_app_labels(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], mode: str):
    if mode == "none":
        return
    x, y, w, h = box
    if mode == "apps":
        labels = ["Safari", "AltTabNeo", "Música"]
    elif mode == "windows":
        labels = ["Inbox", "Settings", "Playlist"]
    else:
        labels = ["Safari — Tab", "AltTabNeo — Code", "Music — Jazz"]
    f = font(max(14, int(h * 0.08)), bold=True)
    slots = [x + int(w * 0.18), x + int(w * 0.5), x + int(w * 0.82)]
    ly = y + h + 6
    for cx, label in zip(slots, labels):
        tw = draw.textlength(label, font=f)
        draw.text((cx - tw / 2, ly), label, fill=(60, 60, 65), font=f)


def cover_top_right_icons(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int]):
    x, y, w, h = box
    bg = BACKGROUND.getpixel((0, 0)) if BACKGROUND else (235, 235, 238)
    draw.rectangle((x + w - 130, y + int(h * 0.02), x + w - 8, y + int(h * 0.12)), fill=bg)


def cover_title_row_badges(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], row: int):
    x, y, w, h = box
    ry = y + int(h * (0.08 + row * 0.31))
    draw.rectangle((x + w - 72, ry, x + w - 8, ry + int(h * 0.28)), fill=(42, 42, 46))


def render(name: str) -> Image.Image:
    flags = parse_name(name)
    style = flags["style"]
    img, box = compose(PANELS[style].copy())
    draw = ImageDraw.Draw(img)

    if style == "thumbnails":
        # Usar el PNG del usuario sin dibujar badges ni círculos encima.
        pass
    elif style == "app_icons":
        draw_app_labels(draw, box, flags["label_mode"])
    elif style == "titles":
        if not flags["show_status"]:
            for row in range(3):
                cover_title_row_badges(draw, box, row)
        elif flags["show_space"]:
            for row in range(2):
                rx = box[0] + box[2] - 14
                ry = box[1] + int(box[3] * (0.1 + row * 0.31))
                draw.ellipse((rx - 24, ry, rx + 4, ry + 24), outline=(200, 200, 205), width=2)
                draw.text((rx - 16, ry + 3), str(2 - row), fill=(200, 200, 205), font=font(13, bold=True))

    return img


def main() -> None:
    load_panels()
    for heic in sorted(OUT.glob("*.heic")):
        stem = heic.stem.replace("@2x", "")
        png = heic.with_suffix(".png")
        render(stem).save(png, "PNG")
        subprocess.run(
            ["sips", "-s", "format", "heic", "-s", "formatOptions", "60", str(png), "--out", str(heic)],
            check=True,
            stdout=subprocess.DEVNULL,
        )
        png.unlink()
        print("ok", heic.name)


if __name__ == "__main__":
    main()
