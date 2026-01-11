#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------
# Configuration
# -------------------------------------------

SOURCE_ROOT="source"
EXPORT_ROOT="export"

# Each rule:
#   "input_svg  size_px  output_suffix"
#
# output filename becomes:
#   <original>_<suffix>.png
#
# If suffix is empty, it uses the size.
#
EXPORT_RULES=(
    # FULL (rectangular, scale by width)
    "full/black_on_transparent.svg 500x 500"
    "full/blue_on_transparent.svg 500x 500"
    "full/white_on_transparent.svg 500x 500"
    
    # ICONS (square)
    "icon/icon_blue_on_transparent.svg 128 128"
    "icon/icon_blue_on_transparent.svg 32  favicon"
    
    "icon/icon_blue_on_white.svg 128 128"
    "icon/icon_blue_on_white.svg 32  favicon"
    
    "icon/icon_white_on_blue.svg 128 128"
    "icon/icon_white_on_blue.svg 32  favicon"
    
    "icon/icon_white_on_transparent.svg 128 128"
    "icon/icon_white_on_transparent.svg 32  favicon"
    
    # WIDE
    "wide/wide_blue_on_transparent.svg 500x 500"
    "wide/wide_blue_on_white.svg 500x 500"
    "wide/wide_white_on_blue.svg 500x 500"
    "wide/wide_white_on_transparent.svg 500x 500"
)


# -------------------------------------------
# Functions
# -------------------------------------------

render_svg() {
    local src="$1"
    local size="$2"
    local dst="$3"

    mkdir -p "$(dirname "$dst")"

    # Skip if up-to-date
    if [[ -f "$dst" && "$dst" -nt "$src" ]]; then
        echo "✓ Up to date: $dst"
        return
    fi

    local args=()

    if [[ "$size" == *x* ]]; then
        # WxH syntax
        local w="${size%x*}"
        local h="${size#*x}"

        [[ -n "$w" ]] && args+=(--export-width="$w")
        [[ -n "$h" ]] && args+=(--export-height="$h")
    else
        # Square
        args+=(--export-width="$size" --export-height="$size")
    fi

    echo "→ Rendering $src → $dst ($size)"

    inkscape \
      "$src" \
      --export-type=png \
      "${args[@]}" \
      --export-filename="$dst"
}


# -------------------------------------------
# Main loop
# -------------------------------------------

for rule in "${EXPORT_RULES[@]}"; do
    read -r rel_src size suffix <<< "$rule"

    src="$SOURCE_ROOT/$rel_src"

    if [[ ! -f "$src" ]]; then
        echo "ERROR: Missing source file: $src"
        exit 1
    fi

    base="${rel_src%.svg}"

    if [[ -z "$suffix" ]]; then
        suffix="$size"
    fi

    dst="$EXPORT_ROOT/${base}_${suffix}.png"

    render_svg "$src" "$size" "$dst"
done

echo "✔ Asset export complete"
