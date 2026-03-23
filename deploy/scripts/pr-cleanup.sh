#!/bin/bash
# Remove a PR preview container and its image
set -euo pipefail

PR_NUMBER="${1:?Usage: pr-cleanup.sh <PR_NUMBER>}"
CONTAINER_NAME="oxo-menus-pr-${PR_NUMBER}"
IMAGE_NAME="oxo-menus-pr-${PR_NUMBER}:latest"

echo "=== Cleaning up PR #${PR_NUMBER} preview ==="

docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true
docker rmi "${IMAGE_NAME}" 2>/dev/null || true

echo "Cleanup complete for PR #${PR_NUMBER}"
