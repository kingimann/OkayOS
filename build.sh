#!/bin/bash
# OkayOS top-level build entry point.
# Uses Docker if a working daemon is available (recommended, reproducible),
# otherwise falls back to a native build on a Debian/Ubuntu host.
set -euo pipefail
cd "$(dirname "$0")"

if docker info >/dev/null 2>&1; then
	echo "==> Building OkayOS with Docker"
	docker build --network host -t okayos-builder .
	docker run --rm --privileged --network host -v "$PWD:/okayos" okayos-builder
else
	echo "==> Docker not available; building natively (requires sudo on Debian/Ubuntu)"
	sudo scripts/build-native.sh
fi

echo
echo "Build complete. Boot your OS with:  ./run.sh"
