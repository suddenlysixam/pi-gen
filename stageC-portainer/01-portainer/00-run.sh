#!/bin/bash
set -euo pipefail

# 1) Install the loader script
install -D -m 0755 "./files/docker-load-images.sh" \
  "${ROOTFS_DIR}/usr/local/sbin/docker-load-images.sh"

# 2) Install the systemd unit
install -D -m 0644 "./files/docker-load-images.service" \
  "${ROOTFS_DIR}/etc/systemd/system/docker-load-images.service"

# 3) Copy every tar from files/docker-images/ -> /opt/images/ (create dir if needed)
mkdir -p "${ROOTFS_DIR}/opt/images"
shopt -s nullglob
for f in ./files/docker-images/*.tar; do
  install -D -m 0644 "$f" "${ROOTFS_DIR}/opt/images/$(basename "$f")"
done
shopt -u nullglob

# 4) Enable the unit inside the target
on_chroot <<'CHROOT'
set -e
systemctl daemon-reload
systemctl enable docker-load-images.service
CHROOT

