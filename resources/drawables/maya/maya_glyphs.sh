#!/bin/bash
# The required font "Maya" must be installed on the system for this script to work.
# It can be obtained from here: https://localfonts.eu/freefonts/greek-free-fonts/unicode-fonts-for-ancient-scripts/maya/
set -e

OUT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$OUT_DIR"

FONT_NAME="Maya"
SIZE=30
POINT_SIZE=42
FG_COLOR="white"
BG_COLOR="none"

echo "Output directory: $OUT_DIR"
echo "Using font: $FONT_NAME"

rm -f number_*.png day_*.png month_*.png

render_glyph() {
  local out="$1"
  local glyph="$2"
  local ptsize="$3"
  echo "Rendering $out (glyph '$glyph') with point size $ptsize"
  magick -size "${SIZE}x${SIZE}" xc:"$BG_COLOR" \
    -font "$FONT_NAME" -pointsize "$ptsize" -fill "$FG_COLOR" -stroke "$FG_COLOR" -strokewidth 0.75 \
    -gravity West -annotate 0 "$glyph" \
    "$out"
}

render_numbers() {
  local out="$1"
  local glyph="$2"
  local ptsize="$3"
  echo "Rendering $out (glyph '$glyph') with point size $ptsize"
  magick -size "15x30" xc:"$BG_COLOR" \
    -font "$FONT_NAME" -pointsize "$ptsize" -fill "$FG_COLOR" -stroke "$FG_COLOR" -strokewidth 0.75 \
    -gravity East -annotate 0 "$glyph" \
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

# Numbers 1–20
for i in "${!numbers[@]}"; do
  idx=$i
  render_numbers "number_${idx}.png" "${numbers[$i]}" 42
done

# Tzolk'in days 1–20
for i in "${!days[@]}"; do
  idx=$((i+1))
  render_glyph "day_${idx}.png" "${days[$i]}" 42
done

# Haab months 1–19
for i in "${!months[@]}"; do
  idx=$((i+1))
  render_glyph "month_${idx}.png" "${months[$i]}" 42
done

echo "All Maya glyph images regenerated from font '$FONT_NAME' using provided glyph sequences."