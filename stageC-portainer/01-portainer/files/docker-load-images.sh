#!/bin/sh
set -eu

IMG_DIR=/opt/images
STAMP_DIR=/var/lib/firstboot.d

# If no tars, nothing to do (ConditionDirectoryNotEmpty handles this too)
[ -d "$IMG_DIR" ] || exit 0

# Wait for Docker to be ready (up to ~30s)
i=0
while ! docker info >/dev/null 2>&1; do
  i=$((i+1))
  [ $i -ge 30 ] && exit 1
  sleep 1
done

mkdir -p "$STAMP_DIR"

# Load every *.tar once
found=0
for tar in "$IMG_DIR"/*.tar; do
  [ -e "$tar" ] || continue
  found=1
  base="$(basename "$tar")"
  stamp="$STAMP_DIR/docker.loaded.$base"

  # Skip if already stamped
  [ -f "$stamp" ] && continue

  # Load (idempotent vs stamp; if you prefer, you can add extra checks here)
  docker load -i "$tar"
  touch "$stamp"
done

# No *.tar files present? exit cleanly
[ "$found" -eq 1 ] || exit 0

