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
# Old live-build (e.g. Ubuntu's) can fail in its legacy bootloader stage after
# the filesystem is already built; don't abort, we assemble the ISO below.
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
echo
echo "================================================================"
echo " OkayOS is ready:  out/OkayOS-amd64.iso"
echo " Boot it in a VM:  ./run.sh"
echo "================================================================"
