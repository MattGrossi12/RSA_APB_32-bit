#!/usr/bin/env bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

rm -r fv

bash "$SCRIPT_DIR/genus_nogui.sh"
bash "$SCRIPT_DIR/lec.sh"
bash "$SCRIPT_DIR/genus_gui.sh"