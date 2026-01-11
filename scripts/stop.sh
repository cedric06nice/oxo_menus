#!/bin/bash
# OXO Menus - Stop Services Script
# Stops all running services

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo "🛑 Stopping OXO Menus Services"
echo "=============================="
echo ""

# Parse arguments
REMOVE_VOLUMES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --remove-data)
            REMOVE_VOLUMES=true
            shift
            ;;
        --help)
            echo "Usage: ./scripts/stop.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --remove-data  Also remove all data volumes (WARNING: deletes database!)"
            echo "  --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./scripts/stop.sh                # Stop services, keep data"
            echo "  ./scripts/stop.sh --remove-data  # Stop services and delete data"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$REMOVE_VOLUMES" = true ]; then
    print_warning "WARNING: This will delete all data (menus, users, uploads)!"
    read -p "Are you sure? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    echo "Stopping services and removing volumes..."
    docker-compose down -v
    print_success "Services stopped and data removed"
else
    echo "Stopping services..."
    docker-compose down
    print_success "Services stopped (data preserved)"
fi

echo ""
echo "Services have been stopped."
echo ""
echo "To start again:   ./scripts/start.sh"
echo "To view status:   docker-compose ps"
echo ""
