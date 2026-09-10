#!/bin/bash
# Build all 3 targets with podman. Output .uf2 files land in artifacts/.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$HOME/.cache/zmk-workspace"
mkdir -p "$WORKSPACE" "$REPO_DIR/artifacts"

if [ ! -f "$REPO_DIR/container-build.sh" ]; then
  echo "FATAL: missing $REPO_DIR/container-build.sh"
  exit 1
fi

if ! command -v podman >/dev/null; then
  exec nix shell nixpkgs#podman nixpkgs#slirp4netns nixpkgs#fuse-overlayfs --command "$0" "$@"
fi

podman run --rm \
  -v "$REPO_DIR:/src:ro" \
  -v "$WORKSPACE:/workspace" \
  -v "$REPO_DIR/container-build.sh:/workspace/container-build.sh:ro" \
  -v "$REPO_DIR/artifacts:/output" \
  zmkfirmware/zmk-build-arm:3.5 bash /workspace/container-build.sh