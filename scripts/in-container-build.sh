#!/bin/bash
# Build steps that run *inside* the Docker builder image (deps already present).
set -euo pipefail
cd /okayos

echo "==> Preparing OkayOS assets (theme + wallpaper)"
scripts/fetch-assets.sh
scripts/make-wallpaper.sh

echo "==> Cleaning any previous build"
lb clean --purge || true

echo "==> Configuring (lb config)"
lb config

echo "==> Building image (lb build)"
lb build || echo "W: lb build returned an error (often the legacy bootloader stage) — will try direct ISO assembly"

echo "==> Collecting ISO"
mkdir -p out
iso="$(ls -1 live-image-*.iso 2>/dev/null | head -1 || true)"
if [ -n "$iso" ]; then
	mv -f "$iso" out/OkayOS-amd64.iso
elif [ -f binary/live/filesystem.squashfs ]; then
	echo "==> live-build did not emit an ISO; assembling it from the built filesystem"
	scripts/assemble-iso.sh
else
	echo "ERROR: build produced neither an ISO nor a usable binary/ tree." >&2
	exit 1
fi
echo "OkayOS is ready: out/OkayOS-amd64.iso"
