#!/usr/bin/env bash
set -euo pipefail

# Setup script for genesys-card-generator
# Creates a local Python virtualenv and installs dependencies.

echo "Setting up genesys-card-generator..."

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
  echo "ERROR: python3 not found. Please install Python 3.8+ and re-run."
  exit 1
fi

VENV_DIR=".venv"

if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment in $VENV_DIR/ ..."
  python3 -m venv "$VENV_DIR"
else
  echo "Virtual environment already exists ($VENV_DIR/), reusing it."
fi

echo "Installing Python dependencies..."
source "$VENV_DIR/bin/activate"
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt

echo ""
echo "Setup completed!"
echo ""
echo "Quick Start:"
echo "  source $VENV_DIR/bin/activate"
echo "  python3 generate.py"
echo ""
echo "For help:"
echo "  python3 generate.py --help"
