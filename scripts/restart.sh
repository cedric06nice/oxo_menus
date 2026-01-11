#!/bin/bash
# OXO Menus - Restart Services Script
# Restarts all running services

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

echo "🔄 Restarting OXO Menus Services"
echo "================================"
echo ""

# Parse arguments
REBUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --rebuild)
            REBUILD=true
            shift
            ;;
        --help)
            echo "Usage: ./scripts/restart.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --rebuild  Rebuild Docker images before restarting"
            echo "  --help     Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./scripts/restart.sh           # Quick restart"
            echo "  ./scripts/restart.sh --rebuild # Rebuild and restart"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$REBUILD" = true ]; then
    print_info "Rebuilding and restarting services..."
    docker-compose down
    docker-compose up -d --build
    print_success "Services rebuilt and restarted"
else
    print_info "Restarting services..."
    docker-compose restart
    print_success "Services restarted"
fi

echo ""
print_info "Waiting for services to be ready..."
sleep 5

echo ""
echo "Service Status:"
echo "---------------"

# Check services
if curl -s http://localhost:8055/server/health > /dev/null 2>&1; then
    print_success "Directus is running at http://localhost:8055"
fi

if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    print_success "Web app is running at http://localhost:8080"
fi

echo ""
echo "View logs: docker-compose logs -f"
echo ""
