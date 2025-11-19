#!/bin/bash

# Maya day glyphs URLs (Wikipedia commons full images)
day_urls=(
"https://upload.wikimedia.org/wikipedia/commons/7/7b/MAYA-g-log-cal-D01-Imix.png"
"https://upload.wikimedia.org/wikipedia/commons/8/8f/MAYA-g-log-cal-D02-Ik.png"
"https://upload.wikimedia.org/wikipedia/commons/4/43/MAYA-g-log-cal-D03-Akbal.png"
"https://upload.wikimedia.org/wikipedia/commons/b/b5/MAYA-g-log-cal-D04-Kan.png"
"https://upload.wikimedia.org/wikipedia/commons/c/ca/MAYA-g-log-cal-D05-Chikchan.png"
"https://upload.wikimedia.org/wikipedia/commons/2/24/MAYA-g-log-cal-D06-Kimi.png"
"https://upload.wikimedia.org/wikipedia/commons/d/d1/MAYA-g-log-cal-D07-Manik.png"
"https://upload.wikimedia.org/wikipedia/commons/a/a8/MAYA-g-log-cal-D08-Lamat.png"
"https://upload.wikimedia.org/wikipedia/commons/c/c5/MAYA-g-log-cal-D09-Muluk.png"
"https://upload.wikimedia.org/wikipedia/commons/1/11/MAYA-g-log-cal-D10-Ok.png"
"https://upload.wikimedia.org/wikipedia/commons/8/84/MAYA-g-log-cal-D11-Chuwen.png"
"https://upload.wikimedia.org/wikipedia/commons/7/70/MAYA-g-log-cal-D12-Eb.png"
"https://upload.wikimedia.org/wikipedia/commons/d/d4/MAYA-g-log-cal-D13-Ben.png"
"https://upload.wikimedia.org/wikipedia/commons/d/d9/MAYA-g-log-cal-D14-Ix.png"
"https://upload.wikimedia.org/wikipedia/commons/f/f6/MAYA-g-log-cal-D15-Men.png"
"https://upload.wikimedia.org/wikipedia/commons/2/2a/MAYA-g-log-cal-D16-Kib.png"
"https://upload.wikimedia.org/wikipedia/commons/0/01/MAYA-g-log-cal-D17-Kaban.png"
"https://upload.wikimedia.org/wikipedia/commons/3/33/MAYA-g-log-cal-D18-Etznab.png"
"https://upload.wikimedia.org/wikipedia/commons/3/38/MAYA-g-log-cal-D19-Kawak.png"
"https://upload.wikimedia.org/wikipedia/commons/1/1b/MAYA-g-log-cal-D20-Ajaw.svg"
)

# Maya month glyphs URLs (Wikipedia commons full images)
haab_urls=(
"https://upload.wikimedia.org/wikipedia/commons/c/ce/1_pop.png"
"https://upload.wikimedia.org/wikipedia/commons/3/35/2_uo_haab.png"
"https://upload.wikimedia.org/wikipedia/commons/1/12/3_sip.png"
"https://upload.wikimedia.org/wikipedia/commons/9/91/4_zotz.png"
"https://upload.wikimedia.org/wikipedia/commons/8/8f/5_tzec.png"
"https://upload.wikimedia.org/wikipedia/commons/1/1d/6_xul.png"
"https://upload.wikimedia.org/wikipedia/commons/1/16/7_yaxkin.png"
"https://upload.wikimedia.org/wikipedia/commons/2/2e/8_mol.png"
"https://upload.wikimedia.org/wikipedia/commons/c/c7/9_chen.png"
"https://upload.wikimedia.org/wikipedia/commons/a/ac/10_yax.png"
"https://upload.wikimedia.org/wikipedia/commons/1/11/11_zac.png"
"https://upload.wikimedia.org/wikipedia/commons/0/0f/12_ceh.png"
"https://upload.wikimedia.org/wikipedia/commons/e/ee/13_mac.png"
"https://upload.wikimedia.org/wikipedia/commons/3/34/14_kankin.png"
"https://upload.wikimedia.org/wikipedia/commons/1/18/15_muan.png"
"https://upload.wikimedia.org/wikipedia/commons/7/70/16_pax.png"
"https://upload.wikimedia.org/wikipedia/commons/9/96/17_kayab.png"
"https://upload.wikimedia.org/wikipedia/commons/8/81/18_cumhu.png"
"https://upload.wikimedia.org/wikipedia/commons/3/31/19_uayeb.png"
)

for i in {1..20}; do
  echo "Processing day_$i"
  curl -s -L -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" "${day_urls[$i-1]}" -o "day_$i.png"
  magick "day_$i.png" -resize 30x30 -colorspace Gray -contrast-stretch 0 -negate "day_$i.png"
  sleep 1
done

for i in {1..19}; do
  echo "Processing month_$i"
  curl -s -L -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" "${haab_urls[$i-1]}" -o "month_$i.png"
  magick "month_$i.png" -negate -background black -flatten -resize 30x30 -colorspace Gray -contrast-stretch 0 "month_$i.png"
  sleep 1
done

# Maya numbers (bars and dots)
# 1: 1 dot
magick -size 16x16 xc:black -fill white -draw "circle 8,8 8,6" number_1.png

# 2: 2 dots
magick -size 16x16 xc:black -fill white -draw "circle 5,8 5,6" -draw "circle 11,8 11,6" number_2.png

# 3: 3 dots
magick -size 16x16 xc:black -fill white -draw "circle 4,8 4,6" -draw "circle 8,8 8,6" -draw "circle 12,8 12,6" number_3.png

# 4: 4 dots
magick -size 16x16 xc:black -fill white -draw "circle 4,5 4,3" -draw "circle 12,5 12,3" -draw "circle 4,11 4,9" -draw "circle 12,11 12,9" number_4.png

# 5: 1 bar
magick -size 16x16 xc:black -fill white -draw "rectangle 2,7 14,9" number_5.png

# 6: bar + 1 dot
magick -size 16x16 xc:black -fill white -draw "rectangle 2,7 14,9" -draw "circle 8,12 8,10" number_6.png

# 7: bar + 2 dots
magick -size 16x16 xc:black -fill white -draw "rectangle 2,7 14,9" -draw "circle 6,12 6,10" -draw "circle 10,12 10,10" number_7.png

# 8: bar + 3 dots
magick -size 16x16 xc:black -fill white -draw "rectangle 2,7 14,9" -draw "circle 5,12 5,10" -draw "circle 8,12 8,10" -draw "circle 11,12 11,10" number_8.png

# 9: 2 bars
magick -size 16x16 xc:black -fill white -draw "rectangle 2,5 14,7" -draw "rectangle 2,9 14,11" number_9.png

# 10: 2 bars (same as 9)
cp number_9.png number_10.png

# 11: 2 bars + 1 dot
magick -size 16x16 xc:black -fill white -draw "rectangle 2,4 14,6" -draw "rectangle 2,8 14,10" -draw "circle 8,13 8,11" number_11.png

# 12: 2 bars + 2 dots
magick -size 16x16 xc:black -fill white -draw "rectangle 2,4 14,6" -draw "rectangle 2,8 14,10" -draw "circle 6,13 6,11" -draw "circle 10,13 10,11" number_12.png

# 13: 2 bars + 3 dots
magick -size 16x16 xc:black -fill white -draw "rectangle 2,4 14,6" -draw "rectangle 2,8 14,10" -draw "circle 5,13 5,11" -draw "circle 8,13 8,11" -draw "circle 11,13 11,11" number_13.png

echo "All images created."