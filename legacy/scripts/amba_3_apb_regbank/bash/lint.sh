#!/bin/sh
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

lec -nogui -dofile ../tcl/lint.tcl
