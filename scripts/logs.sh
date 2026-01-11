#!/bin/bash
# OXO Menus - View Logs Script
# Displays logs from running services

set -e  # Exit on error

# Colors for output
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

echo "📋 OXO Menus Service Logs"
echo "========================="
echo ""

# Parse arguments
SERVICE=""
FOLLOW=true
TAIL=100

while [[ $# -gt 0 ]]; do
    case $1 in
        --directus)
            SERVICE="directus"
            shift
            ;;
        --web)
            SERVICE="web"
            shift
            ;;
        --no-follow)
            FOLLOW=false
            shift
            ;;
        --tail)
            TAIL="$2"
            shift 2
            ;;
        --help)
            echo "Usage: ./scripts/logs.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --directus   Show Directus logs only"
            echo "  --web        Show web app logs only"
            echo "  --no-follow  Don't follow logs (just show recent)"
            echo "  --tail N     Show last N lines (default: 100)"
            echo "  --help       Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./scripts/logs.sh                    # Follow all service logs"
            echo "  ./scripts/logs.sh --directus         # Follow Directus logs only"
            echo "  ./scripts/logs.sh --web --no-follow  # Show recent web logs"
            echo "  ./scripts/logs.sh --tail 50          # Show last 50 lines"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Build docker-compose logs command
CMD="docker-compose logs --tail=$TAIL"

if [ "$FOLLOW" = true ]; then
    CMD="$CMD -f"
fi

if [ -n "$SERVICE" ]; then
    CMD="$CMD $SERVICE"
    print_info "Viewing logs for $SERVICE"
else
    print_info "Viewing logs for all services"
fi

echo ""
echo "Press Ctrl+C to exit"
echo ""

# Execute command
$CMD
