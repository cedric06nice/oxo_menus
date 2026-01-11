#!/bin/bash
# OXO Menus - Development Mode Script
# Starts development environment with hot reload

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

echo "🔧 OXO Menus Development Mode"
echo "============================="
echo ""

# Parse arguments
DEVICE="chrome"
WATCH=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --device)
            DEVICE="$2"
            shift 2
            ;;
        --watch)
            WATCH=true
            shift
            ;;
        --help)
            echo "Usage: ./scripts/dev.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --device <name>  Target device (default: chrome)"
            echo "  --watch          Run build_runner in watch mode"
            echo "  --help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./scripts/dev.sh                    # Run on Chrome"
            echo "  ./scripts/dev.sh --watch            # With code generation watch"
            echo "  ./scripts/dev.sh --device macos     # Run on macOS"
            echo ""
            echo "Available devices:"
            flutter devices --machine | grep -o '"id":"[^"]*"' | cut -d'"' -f4 | sed 's/^/  - /'
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if backend is running
print_info "Checking backend status..."
if ! curl -s http://localhost:8055/server/health > /dev/null 2>&1; then
    print_info "Backend not running. Starting Directus..."
    docker-compose up -d directus
    print_info "Waiting for Directus to be ready..."
    for i in {1..30}; do
        if curl -s http://localhost:8055/server/health > /dev/null 2>&1; then
            print_success "Directus is ready"
            break
        fi
        sleep 1
    done
else
    print_success "Backend is running"
fi

# Start build_runner in watch mode if requested
if [ "$WATCH" = true ]; then
    print_info "Starting code generation watch mode..."
    flutter pub run build_runner watch --delete-conflicting-outputs &
    WATCH_PID=$!
    print_success "Code generation watch started (PID: $WATCH_PID)"

    # Cleanup on exit
    trap "kill $WATCH_PID 2>/dev/null" EXIT
fi

echo ""
print_info "Starting Flutter app on $DEVICE..."
print_info "Hot reload: Press 'r' | Hot restart: Press 'R'"
echo ""

# Run the app
flutter run -d "$DEVICE" --dart-define=DIRECTUS_URL=http://localhost:8055

# Cleanup happens automatically via trap
