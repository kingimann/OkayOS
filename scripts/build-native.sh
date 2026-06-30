#!/bin/bash
# Build OkayOS directly on a Debian/Ubuntu host (no Docker).
# Must run as root because live-build creates a chroot and loop-mounts images.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "$(id -u)" -ne 0 ]; then
	echo "This must run as root. Try:  sudo scripts/build-native.sh"
	exit 1
fi

echo "==> Installing build dependencies"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	live-build debootstrap debian-archive-keyring \
	xorriso squashfs-tools isolinux syslinux-common syslinux-utils \
	mtools dosfstools curl ca-certificates imagemagick fonts-dejavu-core

echo "==> Preparing OkayOS assets (theme + wallpaper)"
scripts/fetch-assets.sh
scripts/make-wallpaper.sh

echo "==> Cleaning any previous build"
lb clean --purge || true

echo "==> Configuring (lb config)"
lb config

echo "==> Building image (lb build) — this downloads packages and takes a while"
lb build

echo "==> Collecting ISO"
mkdir -p out
iso="$(ls -1 live-image-*.iso 2>/dev/null | head -1 || true)"
if [ -z "$iso" ]; then
	echo "ERROR: build finished but no ISO was produced." >&2
	exit 1
fi
mv -f "$iso" out/OkayOS-amd64.iso
echo
echo "================================================================"
echo " OkayOS is ready:  out/OkayOS-amd64.iso"
echo " Boot it in a VM:  ./run.sh"
echo "================================================================"
