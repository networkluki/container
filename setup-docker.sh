#!/usr/bin/env bash
set -euo pipefail

# ===== CONFIG =====
DOCKER_PKG="docker.io"
DOCKER_SERVICE="docker"
CURRENT_USER="${SUDO_USER:-$USER}"

# ===== UTILITY =====
log() {
    echo "[INFO] $1"
}

err() {
    echo "[ERROR] $1" >&2
    exit 1
}

require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        err "This script must be run as root (use sudo)."
    fi
}

# ===== CHECKS =====
require_root

log "Detected user: ${CURRENT_USER}"

if ! command -v apt >/dev/null 2>&1; then
    err "APT not found. This script supports Debian/Ubuntu only."
fi

# ===== SYSTEM UPDATE =====
log "Updating package index..."
apt update -y

# ===== INSTALL DOCKER =====
if dpkg -s "${DOCKER_PKG}" >/dev/null 2>&1; then
    log "Docker already installed."
else
    log "Installing Docker (${DOCKER_PKG})..."
    apt install -y "${DOCKER_PKG}"
fi

# ===== ENABLE & START SERVICE =====
log "Enabling Docker service..."
systemctl enable "${DOCKER_SERVICE}"

log "Starting Docker service..."
systemctl start "${DOCKER_SERVICE}"

# ===== USER GROUP =====
if getent group docker >/dev/null; then
    log "Docker group exists."
else
    log "Creating docker group..."
    groupadd docker
fi

if id "${CURRENT_USER}" | grep -q docker; then
    log "User already in docker group."
else
    log "Adding ${CURRENT_USER} to docker group..."
    usermod -aG docker "${CURRENT_USER}"
    log "User must re-login for group changes to apply."
fi

# ===== BASIC HARDENING =====
log "Applying basic daemon defaults..."

cat >/etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "icc": false,
  "userns-remap": "default"
}
EOF

systemctl restart docker

# ===== VERIFY =====
log "Verifying Docker installation..."
docker --version

log "Running test container..."
docker run --rm hello-world >/dev/null

log "Docker installation completed successfully."
