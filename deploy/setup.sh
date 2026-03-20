#!/bin/bash
# ─── One-time VPS setup script ───
# Run on the VPS as root: sudo bash setup.sh
set -euo pipefail

DOMAIN_FLUTTER_PROD="your-app.example.com"
DOMAIN_API_PROD="api.your-app.example.com"
DOMAIN_API_DEV="api.your-app-dev.example.com"
DEPLOY_USER="directus"
DEPLOY_DIR="/home/${DEPLOY_USER}/oxo-menus"

echo "=== Installing Docker ==="
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ${DEPLOY_USER}
    echo "Docker installed. User '${DEPLOY_USER}' added to docker group."
    echo "NOTE: '${DEPLOY_USER}' must log out and back in for docker group to take effect."
else
    echo "Docker already installed."
fi

echo ""
echo "=== Setting up deploy directory ==="
mkdir -p ${DEPLOY_DIR}/traefik

# Script is expected to run from within ${DEPLOY_DIR}
if [ "$(pwd)" != "${DEPLOY_DIR}" ]; then
    cp docker-compose.yml .env.example ${DEPLOY_DIR}/ 2>/dev/null || true
    cp traefik/traefik.yml ${DEPLOY_DIR}/traefik/ 2>/dev/null || true
fi

echo ""
echo "=== Creating .env file ==="
if [ ! -f "${DEPLOY_DIR}/.env" ]; then
    cp ${DEPLOY_DIR}/.env.example ${DEPLOY_DIR}/.env
    echo "IMPORTANT: Edit ${DEPLOY_DIR}/.env and set all passwords/keys!"
    echo "  Generate UUIDs with: uuidgen"
    echo "  Generate passwords with: openssl rand -base64 32"
else
    echo ".env already exists, skipping."
fi

# Initialize blue/green state
if [ ! -f "${DEPLOY_DIR}/.active-slot" ]; then
    echo "blue" > "${DEPLOY_DIR}/.active-slot"
fi

chown -R ${DEPLOY_USER}:${DEPLOY_USER} ${DEPLOY_DIR}
chmod 600 ${DEPLOY_DIR}/.env

echo ""
echo "=== Installing directus-extension-schema-sync ==="
echo "After first 'docker compose up', install the extension:"
echo "  cd ${DEPLOY_DIR}"
echo "  docker exec oxo-directus-dev npm install directus-extension-schema-sync"
echo "  docker exec oxo-directus-prod npm install directus-extension-schema-sync"
echo "  docker compose restart directus-dev directus-prod"

echo ""
echo "=== Setup complete ==="
echo ""
echo "New .env variables to set:"
echo "  ACME_EMAIL         — Let's Encrypt registration email"
echo "  DOMAIN_FLUTTER_PROD — e.g. oxo-menus.cedric06nice.com"
echo "  DOMAIN_API_PROD    — e.g. api.oxo-menus.cedric06nice.com"
echo "  DOMAIN_API_DEV     — e.g. api-dev.oxo-menus.cedric06nice.com"
echo "  BLUE_ENABLED       — true (default)"
echo "  GREEN_ENABLED      — false (default)"
echo ""
echo "Next steps:"
echo "  1. Edit ${DEPLOY_DIR}/.env with real passwords, keys, and domains"
echo "  2. cd ${DEPLOY_DIR} && docker compose up -d"
echo "  3. Add GitHub secrets:"
echo "     - VPS_HOST (this server's IP or hostname)"
echo "     - SSH_PRIVATE_KEY (SSH key for '${DEPLOY_USER}' user)"
echo "  4. Push to 'prod' branch to trigger deployment"
echo ""
echo "Traefik will automatically obtain TLS certificates on first request."
echo ""
echo "Domains:"
echo "  Flutter prod:  https://${DOMAIN_FLUTTER_PROD}"
echo "  Directus prod: https://${DOMAIN_API_PROD}"
echo "  Directus dev:  https://${DOMAIN_API_DEV}"
