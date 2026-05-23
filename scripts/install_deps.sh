#!/bin/bash

set -euo pipefail

###############################################################################
# Logging
###############################################################################

LOG_FILE="/var/log/docker-setup.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "[INFO] Starting Docker setup"

###############################################################################
# Config
###############################################################################

DOCKER_DATA_ROOT="/mnt/docker-data"
DEVICE="/dev/nvme1n1"
FILESYSTEM="ext4"

###############################################################################
# Wait for device
###############################################################################

echo "[INFO] Waiting for device ${DEVICE}"

for i in {1..30}; do
  if [ -b "${DEVICE}" ]; then
    echo "[INFO] Device detected"
    break
  fi
  sleep 2
done

if [ ! -b "${DEVICE}" ]; then
  echo "[ERROR] Device not found: ${DEVICE}"
  exit 1
fi

###############################################################################
# Format if needed
###############################################################################

echo "[INFO] Checking filesystem"

if ! blkid "${DEVICE}" >/dev/null 2>&1; then
  echo "[INFO] Formatting ${DEVICE} as ${FILESYSTEM}"
  mkfs.ext4 -F "${DEVICE}"
fi

###############################################################################
# Mount volume
###############################################################################

echo "[INFO] Mounting volume"

mkdir -p "${DOCKER_DATA_ROOT}"

UUID=$(blkid -s UUID -o value "${DEVICE}")

if ! grep -q "${UUID}" /etc/fstab; then
  echo "UUID=${UUID} ${DOCKER_DATA_ROOT} ${FILESYSTEM} defaults,nofail 0 2" >> /etc/fstab
fi

mount -a

###############################################################################
# Dependencies
###############################################################################

echo "[INFO] Installing dependencies"

apt update -y
apt install -y ca-certificates curl gnupg

###############################################################################
# Docker repo
###############################################################################

echo "[INFO] Adding Docker repository"

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

###############################################################################
# Install Docker
###############################################################################

echo "[INFO] Installing Docker"

apt update -y

apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

###############################################################################
# Configure Docker
###############################################################################

echo "[INFO] Configuring Docker data-root"

mkdir -p /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "data-root": "${DOCKER_DATA_ROOT}",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF

###############################################################################
# Start Docker
###############################################################################

echo "[INFO] Starting Docker"

systemctl enable docker
systemctl restart docker

###############################################################################
# Validation
###############################################################################

echo "[INFO] Validation"

docker info | grep "Docker Root Dir"
df -h | grep "${DOCKER_DATA_ROOT}"

echo "[INFO] Done"