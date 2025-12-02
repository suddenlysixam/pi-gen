#!/bin/bash
set -euo pipefail

TARGET_DIR="${ROOTFS_DIR}/srv/django-demo"

mkdir -p "${TARGET_DIR}"
shopt -s nullglob
for f in ./files/srv/django-demo/*.html; do
  install -D -m 0644 "$f" "${TARGET_DIR}/$(basename "$f")"
done
shopt -u nullglob
