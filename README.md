# Yu-Gi-Oh! Card Image Generator (Cards + Alias) with (Genesys) Points Overlay

A Python tool to generate Yu-Gi-Oh! card images with Genesys point overlays. It can (1) download official card images from YGOPRODeck using `cards.json`, and (2) apply the same point overlays to pre-downloaded **alias** images using `alias.json` + `alias_images/`.

## Features

- **Direct image downloads** - No API calls needed, uses direct image URLs (YGOPRODeck images)
- **Cards + alias support** - Generate downloaded cards, local alias cards, or both
- **Points overlay** - Automatically adds point values from JSON as visible text on each card
- **Color-coded points** - Background colors change based on point values for quick identification.
- **Smart font sizing** - Automatically scales text size based on image dimensions
- **Simple naming** - Images saved as `{card_code}.jpg` (e.g., `21044178.jpg`)
- **Fast processing** - Efficient image processing with PIL/Pillow
- **Configurable delays** - Respectful rate limiting
- **Comprehensive error handling** - Graceful handling of missing cards or processing errors
- **Progress reporting** - Real-time download and processing progress

## Installation

### Quick Setup (Recommended)

Run the setup script to automatically configure the Python environment:

```bash
./setup.sh
```

### Manual Setup

1. Make sure you have Python 3.8+ installed
2. Create a virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```
3. Install dependencies:
```bash
pip install -r requirements.txt
```

**Note**: The script requires Pillow (PIL) for image processing.

## Usage

The main script is `generate.py`. It orchestrates both phases (downloaded cards + local alias images) and writes everything to a single output directory.

### Basic Usage

To regenerate all cards using the default file paths (`cards.json`, `alias.json`, `alias_images`) and save them to the `generated_cards` directory:

```bash
source .venv/bin/activate  # Activate virtual environment first
python3 generate.py
```

The script will first clean the output directory to ensure a fresh build.

### Generate a Single Card (and its Aliases)

To generate **only one** card defined in `cards.json` (and, if present in `alias.json`, also generate its alias images from `alias_images/`), use `--code`:

```bash
python3 generate.py --code 10443957
```

You can also pass multiple codes (repeat the flag or use a comma-separated list):

```bash
python3 generate.py --code 10443957 --code 14532163
python3 generate.py --code 10443957,14532163
```

### Test Run with a Limit

To test the process on a small number of cards, use the `--limit` option. This will only process the first 10 cards from `cards.json` (and all alias cards).

```bash
python3 generate.py --limit 10
```

### Generate Scope (cards vs alias)

By default the script generates **everything** (`all`). You can choose to run only one phase:

```bash
python3 generate.py --generate cards   # Only cards from cards.json
python3 generate.py --generate alias   # Only aliases (still needs cards.json for point values)
python3 generate.py --generate all     # Both (default)
```

`--code` works with these scopes too:

```bash
python3 generate.py --generate cards --code 10443957  # Only the downloaded card for that code
python3 generate.py --generate alias --code 10443957  # Only aliases for that original code
```

### Advanced Usage

You can customize the paths for input files and the output directory.

```bash
python3 generate.py \
    --cards /path/to/your/cards.json \
    --alias /path/to/your/alias.json \
    --alias-images /path/to/your/local_images \
    --output /path/to/final_destination
```

### Optional: Download-only helper

If you only want to download card images (with overlay) into a separate folder, you can use:

```bash
python3 card_downloader.py --help
```

### Command Line Options

- `-c, --cards`: Path to the cards JSON file (default: `cards.json`).
- `-a, --alias`: Path to the alias JSON file (default: `alias.json`).
- `-i, --alias-images`: Directory with pre-downloaded alias images (default: `alias_images`).
- `-o, --output`: Unified output directory for all generated cards (default: `generated_cards`).
- `-d, --delay`: Delay between downloads in seconds (default: 0.1).
- `-l, --limit`: For testing, limits the number of cards processed from `cards.json` (default: all).
- `-hq, --high-quality`: Generate high quality images (original size) instead of optimized thumbnails.
- `-g, --generate`: What to generate: `all`, `cards`, `alias` (default: `all`).
- `--code`: Generate only a specific card code from `cards.json` (repeatable or comma-separated). When generating aliases, only aliases for these **original** codes are processed.

## JSON File Format

### cards.json

`cards.json` should contain an array of card objects with at least a `code` field:

```json
[
  {
    "code": 21044178,
    "name": "深渊的潜伏者",
    "points": 100
  },
  {
    "code": 98287529,
    "name": "虚龙魔王 无形矢·心灵",
    "points": 67
  }
]
```

Required fields:
- `code`: The Yu-Gi-Oh! card ID/code (integer).
- `points`: The point value (integer) to be overlaid on the card image.

Optional fields:
- `name`: Card name, used for progress messages in the console.

### alias.json

`alias.json` maps an **original** card code (must exist in `cards.json`) to a list of **alias** card codes. Each alias must have a corresponding local image at `alias_images/{alias_code}.jpg`.

```json
{
  "21044178": [14532164, 12580478],
  "98287529": [10802916]
}
```

## Output

All generated images are saved to the output directory (default: `generated_cards`).

- **Standard Mode (Default)**: All cards are resized to a compact size (`177x254`) to optimize file size (approx. 10-30KB per image).
- **High Quality Mode (`--high-quality`)**: Images keep their original resolution (usually larger) for better visual quality, but larger file sizes.
- **File Naming**: Images are saved as `{card_code}.jpg`.

### Point Overlay System

Each card image will have its point value displayed in the **bottom-left corner** with:
- **Large, readable text** - Automatically sized based on image dimensions (minimum 60px)
- **Properly sized colored background** - Rectangle automatically fits the number perfectly
- **Color-coded backgrounds** for quick identification:
  - 🔴 **Red background** (white text): 50+ points
  - 🟠 **Orange background** (black text): 20-49 points  
  - 🟡 **Yellow background** (black text): 10-19 points
  - 🟢 **Green background** (black text): 1-9 points
- **Semi-transparent background** - Points are visible without completely obscuring the card art
- **Centered text** - Numbers are centered within their colored rectangles
- **System font detection** - Works with any suitable font available on the system, with a graceful fallback if none are found.

All images are high-quality JPEG files with the point values clearly overlaid.

## Image Sources

Images are downloaded directly from YGOPRODeck using the URL pattern:
```
https://images.ygoprodeck.com/images/cards/{card_code}.jpg
```

This approach is:
- **Faster** - No API calls required
- **More reliable** - Direct image access
- **Simpler** - Consistent naming scheme

## Rate Limiting

The script includes configurable delays between downloads to be respectful:
- Default: 0.1 seconds (adjustable with `-d`)

You can adjust this value based on your needs, but please be considerate.

## Error Handling

The script handles various error conditions:
- Missing or invalid JSON files
- Network connectivity issues
- Missing card images
- Image processing errors
- File system errors

When a card/alias fails to process, the script logs the error and continues with the remaining items.

## Example Output

```
🧹 Cleaning output directory: /.../generated_cards
💾 Output will be saved to: /.../generated_cards
📉 Standard Mode: ON (Optimized/Thumbnail sizes)

--- Phase 1: Processing Primary Cards (from cards.json) ---
[1/2681] Downloading: 深渊的潜伏者 (Code: 21044178, Points: 100)
  ✅ Generated: 21044178.jpg

...

--- Phase 2: Processing Alias Cards (from alias.json) ---
Processing aliases for: 深渊的潜伏者 (Code: 21044178, Points: 100)
  ✅ Generated: 14532164.jpg

🎉 Full regeneration process completed!
```

## License

This project is provided as-is for educational and personal use. Please respect the terms of service of the YGOPRODeck API and Yu-Gi-Oh! card image copyrights.