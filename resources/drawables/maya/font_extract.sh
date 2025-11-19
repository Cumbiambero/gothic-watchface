#!/bin/bash
set -e

OUT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$OUT_DIR"

FONT_NAME="Maya"         # font name as seen by ImageMagick
SIZE=30                  # PNG size in pixels
POINT_SIZE=40         # Font point size (increased for larger glyphs, will be overridden per type)
FG_COLOR="white"
BG_COLOR="none"          # transparent background

echo "Output directory: $OUT_DIR"
echo "Using font: $FONT_NAME"

# Remove existing generated PNGs
rm -f number_*.png day_*.png month_*.png

render_glyph() {
  local out="$1"
  local glyph="$2"
  local ptsize="$3"
  echo "Rendering $out (glyph '$glyph') with point size $ptsize"
  magick -size "${SIZE}x${SIZE}" xc:"$BG_COLOR" \
    -font "$FONT_NAME" -pointsize "$ptsize" -fill "$FG_COLOR" \
    -gravity center -annotate 0 "$glyph" \
    "$out"
}

render_numbers() {
  local out="$1"
  local glyph="$2"
  local ptsize="$3"
  echo "Rendering $out (glyph '$glyph') with point size $ptsize"
  magick -size "10x30" xc:"$BG_COLOR" \
    -font "$FONT_NAME" -pointsize "$ptsize" -fill "$FG_COLOR" \
    -gravity center -annotate 0 "$glyph" \
    "$out"
}

days=(
"󶟐" "󶟑" "󶟒" "󶟓" "󶟔" "󶟕" "󶟖" "󶟗" "󶟘" "󶟙" \
"󶟚" "󶟛" "󶟜" "󶟝" "󶟞" "󶟟" "󶟠" "󶟡" "󶟢" "󶟣"
)

months=(
"󶟤" "󶟥" "󶟦" "󶟧" "󶟨" "󶟩" "󶟪" "󶟫" "󶟬" "󶟭" \
"󶟮" "󶟯" "󶟰" "󶟱" "󶟲" "󶟳" "󶟴" "󶟵" "󶟶"
)

numbers=(
"󶟽" "󶠢" "󶠣" "󶠤" "󶠥" "󶠦" "󶠧" "󶠨" "󶠩" "󶠪" \
"󶠫" "󶠬" "󶠭" "󶠮" "󶠯" "󶠰" "󶠱" "󶠲" "󶠳" "󶠴"
)

########################
# Numbers 1–20
########################
for i in "${!numbers[@]}"; do
  idx=$i
  render_numbers "number_${idx}.png" "${numbers[$i]}" 40
done

########################
# Tzolk'in days 1–20
########################
for i in "${!days[@]}"; do
  idx=$((i+1))
  render_glyph "day_${idx}.png" "${days[$i]}" 40
done

########################
# Haab months 1–19
########################
for i in "${!months[@]}"; do
  idx=$((i+1))
  render_glyph "month_${idx}.png" "${months[$i]}" 40
done

echo "All Maya glyph images regenerated from font '$FONT_NAME' using provided glyph sequences."