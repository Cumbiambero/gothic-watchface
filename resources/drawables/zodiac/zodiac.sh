#!/bin/bash
set -e

OUT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$OUT_DIR"

FONT_NAME="/Library/Fonts/Arial Unicode.ttf"
SIZE=20
POINT_SIZE=20
FG_COLOR="white"
BG_COLOR="none"

echo "Output directory: $OUT_DIR"
echo "Using font: $FONT_NAME"

rm -f zodiac_*.png

render_glyph() {
  local out="$1"
  local glyph="$2"
  echo "Rendering $out (glyph '$glyph')"
  magick -size "${SIZE}x${SIZE}" xc:"$BG_COLOR" \
    -font "$FONT_NAME" -pointsize "$POINT_SIZE" -fill "$FG_COLOR"  -strokewidth 1 \
    -gravity center -annotate +10+0 "$glyph" \
    "$out"
}

zodiac_symbols=(
"♈︎"  # Aries
"♉︎"  # Taurus
"♊︎"  # Gemini
"♋︎"  # Cancer
"♌︎"  # Leo
"♍︎"  # Virgo
"♎︎"  # Libra
"♏︎"  # Scorpio
"♐︎"  # Sagittarius
"♑︎"  # Capricorn
"♒︎"  # Aquarius
"♓︎"  # Pisces
)

for i in "${!zodiac_symbols[@]}"; do
  render_glyph "zodiac_${i}.png" "${zodiac_symbols[$i]}"
done

echo "All Zodiac glyph images regenerated from font '$FONT_NAME'."