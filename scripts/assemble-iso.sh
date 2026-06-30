#!/bin/bash
# Assemble a bootable hybrid ISO directly from a finished live-build "binary/"
# tree (live/ + isolinux/), using isolinux + xorriso.
#
# Why this exists: very old live-build versions (e.g. the one Ubuntu ships)
# carry an obsolete syslinux/gfxboot bootloader stage that fails against a
# modern Debian filesystem layout, even though the root filesystem itself
# builds fine. This step takes the already-built squashfs/kernel/initrd and
# wraps them in a BIOS-bootable ISO, bypassing that broken stage. Modern
# live-build produces the ISO on its own and never needs this.
set -euo pipefail
cd "$(dirname "$0")/.."

BIN="binary"
OUT="out/OkayOS-amd64.iso"

if [ ! -f "$BIN/live/filesystem.squashfs" ] || [ ! -f "$BIN/live/vmlinuz" ]; then
	echo "ERROR: $BIN/live is missing vmlinuz/filesystem.squashfs — run 'lb build' first." >&2
	exit 1
fi

ISOHDR="/usr/lib/ISOLINUX/isohdpfx.bin"
ISOBIN="/usr/lib/ISOLINUX/isolinux.bin"
MODDIR="/usr/lib/syslinux/modules/bios"
for f in "$ISOHDR" "$ISOBIN" "$MODDIR/vesamenu.c32"; do
	[ -e "$f" ] || { echo "ERROR: missing $f (install isolinux + syslinux-common)." >&2; exit 1; }
done

mkdir -p "$BIN/isolinux"
# Drop any stray subdirectories a failed live-build run may have left behind.
find "$BIN/isolinux" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +

cp -f "$ISOBIN" "$BIN/isolinux/"
for m in ldlinux.c32 libcom32.c32 libutil.c32 vesamenu.c32 menu.c32; do
	cp -f "$MODDIR/$m" "$BIN/isolinux/"
done

# If live-build didn't leave a usable isolinux.cfg, write a minimal one.
if [ ! -f "$BIN/isolinux/live.cfg" ]; then
	cat > "$BIN/isolinux/isolinux.cfg" <<'CFG'
default live
prompt 0
timeout 50
label live
	kernel /live/vmlinuz
	append initrd=/live/initrd.img boot=live components quiet splash hostname=okayos username=okay
CFG
else
	# Use the menu live-build generated, but auto-boot after 5s.
	[ -f "$BIN/isolinux/isolinux.cfg" ] || printf 'include menu.cfg\ndefault vesamenu.c32\nprompt 0\ntimeout 50\n' > "$BIN/isolinux/isolinux.cfg"
	sed -i 's/^timeout .*/timeout 50/' "$BIN/isolinux/isolinux.cfg" || true
fi

mkdir -p out
echo "==> Building $OUT with xorriso"
xorriso -as mkisofs \
	-iso-level 3 -full-iso9660-filenames \
	-volid "OKAYOS" \
	-isohybrid-mbr "$ISOHDR" \
	-eltorito-boot isolinux/isolinux.bin \
	-eltorito-catalog isolinux/boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table \
	-output "$OUT" \
	"$BIN"

echo "==> ISO assembled: $OUT"
ls -lh "$OUT"
