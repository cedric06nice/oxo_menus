#!/bin/bash
# ─── One-time VPS setup script ───
# Run on the VPS as root: sudo bash setup.sh
set -euo pipefail

DOMAIN_FLUTTER_PROD="your-app.example.com"
DOMAIN_FLUTTER_DEV="your-app-dev.example.com"
DOMAIN_API_PROD="api.your-app.example.com"
DOMAIN_API_DEV="api.your-app-dev.example.com"
DEPLOY_USER="directus"
DEPLOY_DIR="/home/${DEPLOY_USER}/oxo-menus"
EMAIL="admin@example.com"

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
echo "=== Installing Certbot ==="
if ! command -v certbot &> /dev/null; then
    apt-get update
    apt-get install -y certbot
    echo "Certbot installed."
else
    echo "Certbot already installed."
fi

echo ""
echo "=== Obtaining SSL certificates ==="
echo "Make sure DNS A records for all 4 domains point to this server!"
echo "  - ${DOMAIN_FLUTTER_PROD}"
echo "  - ${DOMAIN_FLUTTER_DEV}"
echo "  - ${DOMAIN_API_PROD}"
echo "  - ${DOMAIN_API_DEV}"
echo ""

# Stop anything on port 80 temporarily for certbot standalone
docker stop oxo-nginx-proxy 2>/dev/null || true

for DOMAIN in ${DOMAIN_FLUTTER_PROD} ${DOMAIN_FLUTTER_DEV} ${DOMAIN_API_PROD} ${DOMAIN_API_DEV}; do
    echo "--- Requesting certificate for ${DOMAIN} ---"
    certbot certonly --standalone -d ${DOMAIN} \
        --non-interactive --agree-tos --email ${EMAIL} \
        || echo "Certificate for ${DOMAIN} may already exist"
done

echo ""
echo "=== Setting up auto-renewal ==="
cat > /etc/cron.d/certbot-renew << 'CRON'
0 3 * * * root certbot renew --pre-hook "docker stop oxo-nginx-proxy || true" --post-hook "docker start oxo-nginx-proxy || true" --quiet
CRON

echo ""
echo "=== Setting up deploy directory ==="
# Script is expected to run from within ${DEPLOY_DIR}
if [ "$(pwd)" != "${DEPLOY_DIR}" ]; then
    mkdir -p ${DEPLOY_DIR}
    cp docker-compose.yml nginx-proxy.conf .env.example ${DEPLOY_DIR}/ 2>/dev/null || true
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
echo "Next steps:"
echo "  1. Edit ${DEPLOY_DIR}/.env with real passwords and keys"
echo "  2. cd ${DEPLOY_DIR} && docker compose up -d"
echo "  3. Add GitHub secrets:"
echo "     - VPS_HOST (this server's IP or hostname)"
echo "     - SSH_PRIVATE_KEY (SSH key for '${DEPLOY_USER}' user)"
echo "  4. Push to 'develop' or 'main' to trigger deployment"
echo ""
echo "Domains:"
echo "  Flutter prod:  https://${DOMAIN_FLUTTER_PROD}"
echo "  Flutter dev:   https://${DOMAIN_FLUTTER_DEV}"
echo "  Directus prod: https://${DOMAIN_API_PROD}"
echo "  Directus dev:  https://${DOMAIN_API_DEV}"
