# AGENTS.md - Genesys Card Generator

## Project Overview

Python tool that generates Yu-Gi-Oh! card images with Genesys point overlays.
Downloads card art from YGOPRODeck and composites color-coded point badges onto
card images. There are only 3 source files.

**Language:** Python 3.8+
**Dependencies:** `requests`, `Pillow` (managed via `requirements.txt`)

## Project Structure

```
genesys-card-generator/
  generate.py            # Main entry point - orchestrates card + alias generation
  card_downloader.py     # Core library - image download + overlay compositing
  apply_alias_overlay.py # Standalone alias overlay processor (imports card_downloader)
  cards.json             # Card data: array of {name, points, code}
  alias.json             # Maps original card codes -> alias card codes
  alias_images/          # Pre-downloaded alias card images (.jpg)
  requirements.txt       # Python deps (requests, Pillow)
  setup.sh               # Bootstrap script (creates venv, installs deps)
  generated_cards/       # Output directory (gitignored)
  downloaded_cards/      # Alt output directory (gitignored)
```

## Setup & Run Commands

```bash
# First-time setup
./setup.sh
# OR manually:
python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt

# Activate venv (always required before running)
source .venv/bin/activate

# Generate all cards (downloads + alias overlays)
python3 generate.py

# Generate a single card by code
python3 generate.py --code 10443957

# Generate multiple specific cards
python3 generate.py --code 10443957,14532163

# Generate only downloaded cards (no alias)
python3 generate.py --generate cards

# Generate only alias images
python3 generate.py --generate alias

# Test run with limited cards
python3 generate.py --limit 10

# High quality mode (original resolution)
python3 generate.py --high-quality

# Download-only helper (standalone)
python3 card_downloader.py --help
```

## Testing

There are **no tests** in this project. No test framework is configured.
If adding tests, use `pytest` and place test files in a `tests/` directory
following the `test_*.py` naming convention.

## Linting / Formatting

No linting or formatting tools are configured. No `.flake8`, `pyproject.toml`,
`mypy.ini`, or similar config files exist. If adding tooling, prefer `ruff` for
linting+formatting and `mypy` for type checking.

## Code Style Guidelines

### File Structure

Every Python source file follows this structure:
1. Shebang line: `#!/usr/bin/env python3`
2. Module-level docstring (triple-quoted)
3. Standard library imports
4. Third-party imports
5. Local imports
6. One main class
7. A `main()` function with `argparse`
8. `if __name__ == '__main__':` guard

### Imports

- Follow PEP 8 import order: stdlib, third-party, local
- Use `from pathlib import Path` (not `os.path`) for all file path handling
- Use `from typing import Dict, List, Optional` for type hints (Python 3.8 compat)
- Deferred imports are used inside `__init__` or `main()` when the module should
  remain importable without all dependencies (e.g., for `--help` to work)

### Naming Conventions

| Element         | Convention        | Example                        |
|-----------------|-------------------|--------------------------------|
| Classes         | `PascalCase`      | `CardRegenerator`              |
| Methods         | `snake_case`      | `run_regeneration`             |
| Private methods | `_leading_underscore` | `_load_cards_data`         |
| Constants       | `UPPER_SNAKE_CASE`| `BASE_IMAGE_URL`               |
| Variables       | `snake_case`      | `total_cards`, `success_count` |
| CLI arguments   | `--kebab-case`    | `--high-quality`, `--alias-images` |

### Type Hints

- Always add type hints to method signatures (parameters and return types)
- Use `typing` module types (`Dict`, `List`, `Optional`) for Python 3.8 compat
- Do NOT use modern union syntax (`str | None`) - use `Optional[str]` instead

### Docstrings

Use Google-style docstrings with `Args:` and `Returns:` sections:

```python
def process_card(self, card_code: str, points: int) -> bool:
    """
    Process a single card image with overlay.

    Args:
        card_code: The Yu-Gi-Oh! card ID
        points: Point value to overlay

    Returns:
        True if processing succeeded, False otherwise.
    """
```

### Error Handling

- Wrap individual item processing in `try/except` so one failure does not stop
  the batch. Log the error and continue.
- Use specific exceptions where possible: `requests.exceptions.RequestException`,
  `(OSError, IOError)` for file/font operations.
- Use broad `except Exception as e` only as a last-resort catch-all per item.
- Use `sys.exit(1)` for fatal/unrecoverable errors (missing required files, etc.).
- Avoid bare `except:` clauses.

### Console Output

- Use emoji-prefixed print statements for user-facing progress:
  - `"[{i}/{total}]"` for progress counters
- Standard emoji conventions in this codebase:
  - Success: print with prefix (card processed successfully)
  - Error: print with prefix (processing failed)
  - Warning: print with prefix (non-critical issue)
  - Cleanup: print with prefix (directory operations)
  - Stats: print with prefix (summary/statistics)
  - Completion: print with prefix (final success message)

### Class Design

- One class per file, encapsulating all related logic
- State initialized in `__init__` (paths, config, loaded data)
- `card_downloader.py` serves as both a standalone CLI and an importable library
- `generate.py` is the primary entry point that orchestrates the other modules

### File I/O

- Use `pathlib.Path` for all path operations (never raw `os.path`)
- Use `open(..., 'r', encoding='utf-8')` for text/JSON files
- Use `io.BytesIO` for in-memory image manipulation
- Use `shutil.rmtree` for directory cleanup

### CLI Arguments

- Use `argparse.ArgumentParser` for all CLI interfaces
- Provide both short (`-c`) and long (`--cards`) flag variants
- Include sensible defaults for all arguments

## Git Conventions

### Commit Messages

Follow **Conventional Commits** format:
- `feat:` new features
- `fix:` bug fixes
- `refactor:` code restructuring without behavior change
- `chore:` maintenance, data updates
- `docs:` documentation changes

Examples:
```
feat: add support for generating specific card codes with --code option
fix: correct points and code values for "Change of Heart"
chore: update genesys points 30/01/26
refactor: adjust font scale for high quality mode
```

### Branch Strategy

Single branch: `main`. All work is done directly on main.

### What NOT to Commit

The `.gitignore` excludes: virtual environments (`.venv/`, `venv/`), generated
output directories (`generated_cards/`, `downloaded_cards/`), Python bytecode
(`__pycache__/`, `*.pyc`), IDE files, OS files, and `.zip` archives.
