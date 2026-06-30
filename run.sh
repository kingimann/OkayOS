#!/bin/bash
# Boot the OkayOS ISO in a QEMU virtual machine.
# Usage: ./run.sh [path-to-iso]
set -euo pipefail
cd "$(dirname "$0")"

ISO="${1:-out/OkayOS-amd64.iso}"
if [ ! -f "$ISO" ]; then
	echo "ISO not found: $ISO"
	echo "Build it first with:  ./build.sh"
	exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
	echo "qemu-system-x86_64 is not installed."
	echo "  Debian/Ubuntu:  sudo apt install qemu-system-x86"
	exit 1
fi

ACCEL=()
if [ -e /dev/kvm ] && [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
	ACCEL=(-enable-kvm -cpu host)
else
	echo "(no KVM access — running without hardware acceleration, will be slower)"
fi

exec qemu-system-x86_64 \
	"${ACCEL[@]}" \
	-m 2048 -smp 2 \
	-vga virtio -display gtk,gl=off \
	-cdrom "$ISO" -boot d
