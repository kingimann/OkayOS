#!/bin/bash
# Downloads the Windows-style GTK theme + icon theme into the live system tree.
# Non-fatal: if a download fails, the build continues and falls back to the
# default theme (so you still get a bootable ISO).
set -uo pipefail
cd "$(dirname "$0")/.."

THEMES_DIR="config/includes.chroot/usr/share/themes"
ICONS_DIR="config/includes.chroot/usr/share/icons"
mkdir -p "$THEMES_DIR" "$ICONS_DIR"

fetch() {
	# $1 = codeload tarball url, $2 = destination dir (theme/icon root)
	local url="$1" dest="$2" tmp
	if [ -d "$dest" ] && [ -n "$(ls -A "$dest" 2>/dev/null)" ]; then
		echo "I: $dest already present, skipping download"
		return 0
	fi
	tmp="$(mktemp -d)"
	echo "I: downloading $url"
	if curl -fsSL "$url" -o "$tmp/a.tgz"; then
		mkdir -p "$dest"
		# Strip the top-level "<repo>-<branch>" directory from the tarball.
		tar -xzf "$tmp/a.tgz" -C "$dest" --strip-components=1
		echo "I: installed -> $dest"
	else
		echo "W: failed to download $url (will fall back to default theme)"
	fi
	rm -rf "$tmp"
}

# B00merang Windows-10 GTK theme and matching icon set.
fetch "https://codeload.github.com/B00merang-Project/Windows-10/tar.gz/refs/heads/master" \
	"$THEMES_DIR/Windows-10"
fetch "https://codeload.github.com/B00merang-Artwork/Windows-10/tar.gz/refs/heads/master" \
	"$ICONS_DIR/Windows-10"

echo "I: asset fetch complete"
