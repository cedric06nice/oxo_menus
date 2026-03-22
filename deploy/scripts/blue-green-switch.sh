#!/bin/bash
# Blue/green deployment switch for OXO Menus production
set -euo pipefail

DEPLOY_DIR="${HOME}/oxo-menus"
SLOT_FILE="${DEPLOY_DIR}/.active-slot"
ENV_FILE="${DEPLOY_DIR}/.env"

# Determine current and next slot
ACTIVE_SLOT=$(cat "${SLOT_FILE}" 2>/dev/null || echo "blue")
if [ "${ACTIVE_SLOT}" = "blue" ]; then
  NEXT_SLOT="green"
else
  NEXT_SLOT="blue"
fi

echo "=== Blue/Green Switch ==="
echo "Active: ${ACTIVE_SLOT} → Next: ${NEXT_SLOT}"

# Load new image
echo "Loading Docker image..."
docker load < /tmp/image.tar.gz

# Enable next slot, disable active slot
echo "Updating .env..."
if [ "${NEXT_SLOT}" = "blue" ]; then
  sed -i 's/^BLUE_ENABLED=.*/BLUE_ENABLED=true/' "${ENV_FILE}"
  sed -i 's/^GREEN_ENABLED=.*/GREEN_ENABLED=false/' "${ENV_FILE}"
else
  sed -i 's/^BLUE_ENABLED=.*/BLUE_ENABLED=false/' "${ENV_FILE}"
  sed -i 's/^GREEN_ENABLED=.*/GREEN_ENABLED=true/' "${ENV_FILE}"
fi

# Recreate both slots
echo "Recreating containers..."
cd "${DEPLOY_DIR}"
docker compose up -d --force-recreate --no-deps oxo-menus-blue oxo-menus-green

# Health check the next slot
echo "Health checking ${NEXT_SLOT} slot..."
CONTAINER="oxo-menus-${NEXT_SLOT}"
RETRIES=10
HEALTHY=false

for i in $(seq 1 ${RETRIES}); do
  if docker exec "${CONTAINER}" wget --quiet --tries=1 --spider http://127.0.0.1/ 2>/dev/null; then
    HEALTHY=true
    break
  fi
  echo "  Attempt ${i}/${RETRIES}..."
  sleep 2
done

if [ "${HEALTHY}" = true ]; then
  echo "${NEXT_SLOT}" > "${SLOT_FILE}"
  echo "Switch complete. Active slot: ${NEXT_SLOT}"
  rm -f /tmp/image.tar.gz
else
  echo "ERROR: ${NEXT_SLOT} slot failed health check. Rolling back..."
  # Revert .env
  if [ "${ACTIVE_SLOT}" = "blue" ]; then
    sed -i 's/^BLUE_ENABLED=.*/BLUE_ENABLED=true/' "${ENV_FILE}"
    sed -i 's/^GREEN_ENABLED=.*/GREEN_ENABLED=false/' "${ENV_FILE}"
  else
    sed -i 's/^BLUE_ENABLED=.*/BLUE_ENABLED=false/' "${ENV_FILE}"
    sed -i 's/^GREEN_ENABLED=.*/GREEN_ENABLED=true/' "${ENV_FILE}"
  fi
  docker compose up -d --force-recreate --no-deps oxo-menus-blue oxo-menus-green
  exit 1
fi
