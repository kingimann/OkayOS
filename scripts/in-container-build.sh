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
lb build

echo "==> Collecting ISO"
mkdir -p out
iso="$(ls -1 live-image-*.iso 2>/dev/null | head -1 || true)"
if [ -z "$iso" ]; then
	echo "ERROR: build finished but no ISO was produced." >&2
	exit 1
fi
mv -f "$iso" out/OkayOS-amd64.iso
echo "OkayOS is ready: out/OkayOS-amd64.iso"
