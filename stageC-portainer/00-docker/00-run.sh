#!/bin/bash
set -euo pipefail

mkdir -p "${ROOTFS_DIR}/petcontainer"
shopt -s nullglob
for f in ./files/site/*; do
  install -D -m 0644 "$f" "${ROOTFS_DIR}/petcontainer/$(basename "$f")"
done
shopt -u nullglob

on_chroot <<'CHROOT'
set -e
apt-get update
apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc || true
apt-get install -y ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
> /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

getent group docker >/dev/null 2>&1 || groupadd docker
usermod -aG docker "${FIRST_USER_NAME}"

systemctl enable docker.service
systemctl enable containerd.service
CHROOT

