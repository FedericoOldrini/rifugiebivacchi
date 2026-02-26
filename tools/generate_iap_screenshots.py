#!/usr/bin/env python3
"""
Genera screenshot mockup della schermata donazioni per la review IAP su App Store Connect.

Apple richiede uno screenshot di review per ogni In-App Purchase.
Questo script crea un'immagine PNG che replica la DonationsScreen dell'app
con i colori e lo stile del tema reale.

Requisiti:
- Python 3.7+
- Pillow: pip3 install Pillow

Uso:
    python3 tools/generate_iap_screenshots.py

Output:
    screenshots/iap_review/iap_review_coffee.png
    screenshots/iap_review/iap_review_lunch.png
    screenshots/iap_review/iap_review_generous.png
"""

import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("❌ Pillow non trovato. Installa con: pip3 install Pillow")
    sys.exit(1)

# ── Configurazione ────────────────────────────────────────────────────────────

PROJECT_ROOT = Path(__file__).parent.parent
OUTPUT_DIR = PROJECT_ROOT / "screenshots" / "iap_review"

# Dimensioni screenshot (Apple richiede min 640x920 per IAP review)
WIDTH = 1290
HEIGHT = 2796

# Colori dal tema app (AppTheme - light mode)
DEEP_TEAL = (44, 95, 93)  # #2C5F5D - primary
PRIMARY_CONTAINER = (178, 212, 210)  # #B2D4D2 - primaryContainer
SURFACE = (242, 245, 246)  # #F2F5F6 - surface
ON_SURFACE = (26, 31, 33)  # #1A1F21 - onSurface
SURFACE_CONTAINER = (236, 240, 241)  # #ECF0F1 - surfaceContainer
ON_SURFACE_VARIANT = (62, 69, 71)  # #3E4547 - onSurfaceVariant
GREY_600 = (117, 117, 117)  # Colors.grey[600]
GREY_700 = (97, 97, 97)  # Colors.grey[700]
WHITE = (255, 255, 255)

# Colori delle donation card
BROWN = (121, 85, 72)  # Colors.brown
BROWN_BG = (121, 85, 72, 51)  # Colors.brown.withOpacity(0.2) → ~20%
ORANGE = (255, 152, 0)  # Colors.orange
ORANGE_BG = (255, 152, 0, 51)
PURPLE = (156, 39, 176)  # Colors.purple
PURPLE_BG = (156, 39, 176, 51)

# Prodotti IAP
PRODUCTS = [
    {
        "id": "rifugi_donation_coffee",
        "title": "Offrimi un caffè",
        "price": "€ 2,99",
        "icon": "☕",
        "color": BROWN,
        "color_bg": (239, 229, 225),  # brown 20% su bianco
        "filename": "iap_review_coffee.png",
    },
    {
        "id": "rifugi_donation_lunch",
        "title": "Offrimi un pranzo",
        "price": "€ 9,99",
        "icon": "🍕",
        "color": ORANGE,
        "color_bg": (255, 243, 224),  # orange 20% su bianco
        "filename": "iap_review_lunch.png",
    },
    {
        "id": "rifugi_donation_generous",
        "title": "Donazione generosa",
        "price": "€ 19,99",
        "icon": "🎁",
        "color": PURPLE,
        "color_bg": (243, 229, 245),  # purple 20% su bianco
        "filename": "iap_review_generous.png",
    },
]

# Feature items (perché donare)
FEATURES = [
    ("🔄", "Aggiornamenti regolari", "Nuovi rifugi e dati aggiornati"),
    ("📍", "Più rifugi", "Ampliamento continuo del database"),
    ("🐛", "Supporto e bugfix", "Correzione bug e miglioramenti"),
    ("✨", "Nuove funzionalità", "Sviluppo di nuove feature"),
]


# ── Utility per il disegno ────────────────────────────────────────────────────


def load_font(size: int) -> ImageFont.FreeTypeFont:
    """Carica un font di sistema"""
    font_paths = [
        "/System/Library/Fonts/SFPro-Regular.otf",
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
    ]
    for fp in font_paths:
        try:
            return ImageFont.truetype(fp, size)
        except (IOError, OSError):
            continue
    return ImageFont.load_default()


def load_font_bold(size: int) -> ImageFont.FreeTypeFont:
    """Carica un font bold di sistema"""
    font_paths = [
        "/System/Library/Fonts/SFPro-Bold.otf",
        "/System/Library/Fonts/SFPro-Semibold.otf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial Bold.ttf",
    ]
    for fp in font_paths:
        try:
            return ImageFont.truetype(fp, size)
        except (IOError, OSError):
            continue
    return ImageFont.load_default()


def draw_rounded_rect(
    draw: ImageDraw.ImageDraw,
    xy: tuple,
    radius: int,
    fill=None,
    outline=None,
    width=0,
):
    """Disegna un rettangolo arrotondato"""
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def get_text_height(draw: ImageDraw.ImageDraw, text: str, font) -> int:
    """Calcola l'altezza del testo"""
    bbox = draw.textbbox((0, 0), text, font=font)
    return bbox[3] - bbox[1]


def get_text_width(draw: ImageDraw.ImageDraw, text: str, font) -> int:
    """Calcola la larghezza del testo"""
    bbox = draw.textbbox((0, 0), text, font=font)
    return bbox[2] - bbox[0]


# ── Generazione screenshot ────────────────────────────────────────────────────


def generate_iap_screenshot(highlight_product_index: int) -> Image.Image:
    """
    Genera uno screenshot mockup della schermata donazioni.
    highlight_product_index: indice del prodotto da evidenziare (0, 1, 2)
    """
    # Crea immagine base
    img = Image.new("RGB", (WIDTH, HEIGHT), SURFACE)
    draw = ImageDraw.Draw(img)

    # Font
    font_title_large = load_font_bold(64)
    font_title = load_font_bold(52)
    font_body = load_font(44)
    font_body_small = load_font(38)
    font_subtitle = load_font(36)
    font_emoji = load_font(72)
    font_emoji_small = load_font(56)
    font_appbar = load_font_bold(54)
    font_price = load_font_bold(44)
    font_arrow = load_font(40)
    font_heart = load_font(160)
    font_info_icon = load_font(48)

    padding = 48
    card_padding = 56
    x_start = padding
    x_end = WIDTH - padding
    card_width = x_end - x_start

    y = 0

    # ── Status bar area (simulata) ──
    y += 130

    # ── AppBar ──
    appbar_text = "Donazioni"
    tw = get_text_width(draw, appbar_text, font_appbar)
    draw.text(((WIDTH - tw) // 2, y), appbar_text, fill=ON_SURFACE, font=font_appbar)
    # Freccia back
    draw.text((padding, y), "‹", fill=DEEP_TEAL, font=load_font_bold(70))
    y += 100

    # Linea separatore sottile
    draw.line([(0, y), (WIDTH, y)], fill=(220, 225, 228), width=2)
    y += 30

    # ── Header Card (cuore + titolo + descrizione) ──
    header_h = 420
    draw_rounded_rect(
        draw,
        (x_start, y, x_end, y + header_h),
        radius=24,
        fill=PRIMARY_CONTAINER,
    )

    # Cuore emoji
    heart_text = "❤️"
    htw = get_text_width(draw, heart_text, font_heart)
    draw.text(((WIDTH - htw) // 2, y + 30), heart_text, fill=DEEP_TEAL, font=font_heart)

    # Titolo "Supporta lo Sviluppo"
    header_title = "Supporta lo Sviluppo"
    htw2 = get_text_width(draw, header_title, font_title_large)
    draw.text(
        ((WIDTH - htw2) // 2, y + 200),
        header_title,
        fill=ON_SURFACE,
        font=font_title_large,
    )

    # Descrizione
    desc = "Se ti piace questa app, considera"
    desc2 = "di fare una donazione!"
    dw1 = get_text_width(draw, desc, font_body_small)
    dw2 = get_text_width(draw, desc2, font_body_small)
    draw.text(((WIDTH - dw1) // 2, y + 290), desc, fill=GREY_700, font=font_body_small)
    draw.text(((WIDTH - dw2) // 2, y + 335), desc2, fill=GREY_700, font=font_body_small)

    y += header_h + 50

    # ── "Perché donare?" ──
    draw.text((x_start, y), "Perché donare?", fill=ON_SURFACE, font=font_title)
    y += 80

    # Feature items
    for emoji, title, desc in FEATURES:
        # Emoji icona
        draw.text((x_start, y - 4), emoji, fill=DEEP_TEAL, font=font_emoji_small)
        # Titolo
        draw.text((x_start + 80, y), title, fill=ON_SURFACE, font=load_font_bold(42))
        # Descrizione
        draw.text((x_start + 80, y + 50), desc, fill=GREY_700, font=font_body_small)
        y += 110

    y += 40

    # ── "Opzioni di donazione" ──
    draw.text((x_start, y), "Opzioni di donazione", fill=ON_SURFACE, font=font_title)
    y += 80

    # ── Donation Cards ──
    for i, product in enumerate(PRODUCTS):
        card_h = 150
        is_highlighted = i == highlight_product_index

        # Card background
        card_fill = WHITE if not is_highlighted else (240, 248, 247)
        card_outline = DEEP_TEAL if is_highlighted else (220, 225, 228)
        card_outline_width = 5 if is_highlighted else 2

        draw_rounded_rect(
            draw,
            (x_start, y, x_end, y + card_h),
            radius=24,
            fill=card_fill,
            outline=card_outline,
            width=card_outline_width,
        )

        # Container icona con sfondo colorato
        icon_box_size = 100
        icon_x = x_start + 28
        icon_y = y + (card_h - icon_box_size) // 2
        draw_rounded_rect(
            draw,
            (icon_x, icon_y, icon_x + icon_box_size, icon_y + icon_box_size),
            radius=20,
            fill=product["color_bg"],
        )

        # Emoji icona centrata nel box
        ew = get_text_width(draw, product["icon"], font_emoji_small)
        eh = get_text_height(draw, product["icon"], font_emoji_small)
        draw.text(
            (
                icon_x + (icon_box_size - ew) // 2,
                icon_y + (icon_box_size - eh) // 2 - 4,
            ),
            product["icon"],
            font=font_emoji_small,
        )

        # Titolo e prezzo
        text_x = icon_x + icon_box_size + 30
        draw.text(
            (text_x, y + 32),
            product["title"],
            fill=ON_SURFACE,
            font=load_font_bold(44),
        )
        draw.text(
            (text_x, y + 86), product["price"], fill=GREY_600, font=font_body_small
        )

        # Freccia ›
        arrow = "›"
        aw = get_text_width(draw, arrow, font_arrow)
        draw.text(
            (x_end - 50 - aw, y + (card_h - 44) // 2),
            arrow,
            fill=GREY_600,
            font=font_arrow,
        )

        y += card_h + 20

    y += 30

    # ── Info card in basso ──
    info_h = 180
    draw_rounded_rect(
        draw,
        (x_start, y, x_end, y + info_h),
        radius=24,
        fill=(245, 245, 245),
    )

    # Icona info
    info_icon = "ℹ️"
    iiw = get_text_width(draw, info_icon, font_info_icon)
    draw.text(((WIDTH - iiw) // 2, y + 20), info_icon, font=font_info_icon)

    info_text = "Le donazioni sono pagamenti una tantum"
    info_text2 = "e non comportano abbonamenti."
    it1w = get_text_width(draw, info_text, font_subtitle)
    it2w = get_text_width(draw, info_text2, font_subtitle)
    draw.text(
        ((WIDTH - it1w) // 2, y + 85),
        info_text,
        fill=GREY_700,
        font=font_subtitle,
    )
    draw.text(
        ((WIDTH - it2w) // 2, y + 125),
        info_text2,
        fill=GREY_700,
        font=font_subtitle,
    )
    y += info_h + 30

    # ── "Grazie per il tuo supporto!" ──
    thanks = "Grazie per il tuo supporto! ❤️"
    tw = get_text_width(draw, thanks, load_font_bold(46))
    draw.text(
        ((WIDTH - tw) // 2, y),
        thanks,
        fill=DEEP_TEAL,
        font=load_font_bold(46),
    )

    return img


def main():
    print(f"\n{'=' * 60}")
    print(f"🏔️  Generazione Screenshot IAP Review")
    print(f"{'=' * 60}\n")

    # Crea directory output
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for i, product in enumerate(PRODUCTS):
        print(f"📸 Generazione screenshot per: {product['title']}...")

        img = generate_iap_screenshot(highlight_product_index=i)

        output_path = OUTPUT_DIR / product["filename"]
        img.save(str(output_path), "PNG", quality=95, optimize=True)

        file_size = output_path.stat().st_size / 1024
        print(
            f"   ✅ Salvato: {output_path.name} ({WIDTH}x{HEIGHT}, {file_size:.0f} KB)"
        )

    print(f"\n{'=' * 60}")
    print(f"✅ Screenshot IAP generati in: {OUTPUT_DIR}")
    print(f"   - {PRODUCTS[0]['filename']} (☕ Caffè - evidenziato)")
    print(f"   - {PRODUCTS[1]['filename']} (🍕 Pranzo - evidenziato)")
    print(f"   - {PRODUCTS[2]['filename']} (🎁 Generosa - evidenziato)")
    print(f"\n📤 Prossimo passo: upload su App Store Connect")
    print(f"{'=' * 60}\n")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n❌ Errore: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)
