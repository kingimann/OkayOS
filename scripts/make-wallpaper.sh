#!/bin/bash
# Generates the OkayOS desktop wallpaper with ImageMagick.
# A Windows-ish blue gradient with the OkayOS name.
set -uo pipefail
cd "$(dirname "$0")/.."

OUT="config/includes.chroot/usr/share/backgrounds/okayos/wallpaper.png"
mkdir -p "$(dirname "$OUT")"

# ImageMagick 7 uses `magick`, IM6 uses `convert`.
if command -v magick >/dev/null 2>&1; then
	IM="magick"
elif command -v convert >/dev/null 2>&1; then
	IM="convert"
else
	echo "W: ImageMagick not found, skipping wallpaper generation"
	exit 0
fi

"$IM" -size 1920x1080 gradient:'#0a2a5e'-'#1e63c4' \
	-gravity center \
	-font DejaVu-Sans-Bold -pointsize 130 -fill white \
	-annotate +0-40 'OkayOS' \
	-font DejaVu-Sans -pointsize 34 -fill '#cfe0ff' \
	-annotate +0+70 "It's gonna be okay." \
	"$OUT" && echo "I: wallpaper -> $OUT" || echo "W: wallpaper generation failed"
