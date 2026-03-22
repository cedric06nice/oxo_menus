#!/bin/bash
# Deploy a PR preview container with Traefik labels
set -euo pipefail

PR_NUMBER="${1:?Usage: pr-deploy.sh <PR_NUMBER>}"
CONTAINER_NAME="oxo-menus-pr-${PR_NUMBER}"
IMAGE_NAME="oxo-menus-pr-${PR_NUMBER}:latest"

# Source base domain from .env
DEPLOY_DIR="${HOME}/oxo-menus"
# shellcheck disable=SC1091
source "${DEPLOY_DIR}/.env"
BASE_DOMAIN="${DOMAIN_FLUTTER_PROD:?DOMAIN_FLUTTER_PROD must be set in .env}"
DOMAIN="pr-${PR_NUMBER}.${BASE_DOMAIN}"

echo "=== Deploying PR #${PR_NUMBER} preview ==="

# Load image
echo "Loading Docker image..."
docker load < /tmp/image.tar.gz

# Stop and remove existing container if present
docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true

# Run with Traefik labels
echo "Starting container..."
docker run -d \
  --name "${CONTAINER_NAME}" \
  --network oxo-network \
  --restart unless-stopped \
  --label "traefik.enable=true" \
  --label "traefik.http.routers.${CONTAINER_NAME}.rule=Host(\`${DOMAIN}\`)" \
  --label "traefik.http.routers.${CONTAINER_NAME}.entrypoints=websecure" \
  --label "traefik.http.routers.${CONTAINER_NAME}.tls.certresolver=letsencrypt" \
  --label "traefik.http.services.${CONTAINER_NAME}.loadbalancer.server.port=80" \
  "${IMAGE_NAME}"

echo "Preview deployed: https://${DOMAIN}/"
