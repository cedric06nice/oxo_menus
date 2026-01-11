#!/bin/bash
# OXO Menus - Start Services Script
# Starts the backend (Directus) and optionally the web app

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

echo "🚀 Starting OXO Menus Services"
echo "=============================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running"
    echo "Please start Docker Desktop and try again"
    exit 1
fi

# Parse arguments
START_WEB=false
BUILD_WEB=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --web)
            START_WEB=true
            shift
            ;;
        --build-web)
            BUILD_WEB=true
            shift
            ;;
        --help)
            echo "Usage: ./scripts/start.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --web         Also start the web app service"
            echo "  --build-web   Build and start the web app (rebuilds Docker image)"
            echo "  --help        Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./scripts/start.sh              # Start Directus only"
            echo "  ./scripts/start.sh --web        # Start Directus and web app"
            echo "  ./scripts/start.sh --build-web  # Rebuild and start all services"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Start services
if [ "$BUILD_WEB" = true ]; then
    print_info "Building and starting all services..."
    docker-compose up -d --build
    print_success "All services started (with rebuild)"
elif [ "$START_WEB" = true ]; then
    print_info "Starting all services..."
    docker-compose up -d
    print_success "All services started"
else
    print_info "Starting Directus backend..."
    docker-compose up -d directus
    print_success "Directus backend started"
fi

echo ""
print_info "Waiting for services to be ready..."
sleep 5

# Check service health
echo ""
echo "Service Status:"
echo "---------------"

# Check Directus
if curl -s http://localhost:8055/server/health > /dev/null 2>&1; then
    print_success "Directus is running at http://localhost:8055"
else
    print_warning "Directus is starting up... (may take a minute)"
fi

# Check Web App (if started)
if [ "$START_WEB" = true ] || [ "$BUILD_WEB" = true ]; then
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        print_success "Web app is running at http://localhost:8080"
    else
        print_warning "Web app is starting up... (may take a minute)"
    fi
fi

echo ""
echo "Quick Commands:"
echo "---------------"
echo "View logs:        docker-compose logs -f"
echo "Stop services:    ./scripts/stop.sh"
echo "Restart services: ./scripts/restart.sh"
echo "Service status:   docker-compose ps"
echo ""

if [ "$START_WEB" = false ] && [ "$BUILD_WEB" = false ]; then
    print_info "To run the Flutter app locally:"
    echo "  flutter run -d chrome --dart-define=DIRECTUS_URL=http://localhost:8055"
    echo ""
fi

print_success "Services are ready!"
