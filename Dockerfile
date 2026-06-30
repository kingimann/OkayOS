# Reproducible OkayOS build environment.
# Matches the target distro (Debian bookworm) so live-build behaves predictably.
FROM debian:bookworm

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		live-build debootstrap debian-archive-keyring \
		xorriso squashfs-tools isolinux syslinux-common syslinux-utils \
		mtools dosfstools curl ca-certificates imagemagick fonts-dejavu-core \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /okayos
ENTRYPOINT ["/okayos/scripts/in-container-build.sh"]
