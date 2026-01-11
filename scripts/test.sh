#!/bin/bash
# OXO Menus - Test Script
# Runs tests with various options

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo "🧪 OXO Menus Test Suite"
echo "======================="
echo ""

# Parse arguments
COVERAGE=false
WATCH=false
INTEGRATION=false
UNIT_ONLY=false
WIDGET_ONLY=false
SPECIFIC_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage)
            COVERAGE=true
            shift
            ;;
        --watch)
            WATCH=true
            shift
            ;;
        --integration)
            INTEGRATION=true
            shift
            ;;
        --unit)
            UNIT_ONLY=true
            shift
            ;;
        --widget)
            WIDGET_ONLY=true
            shift
            ;;
        --file)
            SPECIFIC_FILE="$2"
            shift 2
            ;;
        --help)
            echo "Usage: ./scripts/test.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --coverage     Generate coverage report"
            echo "  --watch        Watch mode (rerun on changes)"
            echo "  --integration  Run integration tests"
            echo "  --unit         Run unit tests only"
            echo "  --widget       Run widget tests only"
            echo "  --file PATH    Run specific test file"
            echo "  --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./scripts/test.sh                      # Run all tests"
            echo "  ./scripts/test.sh --coverage           # With coverage"
            echo "  ./scripts/test.sh --unit               # Unit tests only"
            echo "  ./scripts/test.sh --file test/unit/... # Specific file"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Build test command
CMD="flutter test"

if [ "$INTEGRATION" = true ]; then
    print_info "Running integration tests..."
    CMD="flutter test integration_test/"
elif [ "$UNIT_ONLY" = true ]; then
    print_info "Running unit tests only..."
    CMD="flutter test test/unit/"
elif [ "$WIDGET_ONLY" = true ]; then
    print_info "Running widget tests only..."
    CMD="flutter test test/widget/"
elif [ -n "$SPECIFIC_FILE" ]; then
    print_info "Running test file: $SPECIFIC_FILE"
    CMD="flutter test $SPECIFIC_FILE"
else
    print_info "Running all tests..."
fi

if [ "$COVERAGE" = true ]; then
    CMD="$CMD --coverage"
fi

if [ "$WATCH" = true ]; then
    # Watch mode using entr (if available)
    if command -v entr &> /dev/null; then
        print_info "Starting watch mode (using entr)..."
        find lib test -name '*.dart' | entr -c $CMD
    else
        print_error "Watch mode requires 'entr' to be installed"
        echo "Install with: brew install entr (macOS) or apt install entr (Linux)"
        exit 1
    fi
else
    # Run tests
    $CMD

    # Check result
    if [ $? -eq 0 ]; then
        echo ""
        print_success "All tests passed!"

        # Generate coverage report if requested
        if [ "$COVERAGE" = true ]; then
            echo ""
            print_info "Calculating coverage..."

            # Calculate coverage percentage
            TOTAL_LINES=$(grep -o "LF:[0-9]*" coverage/lcov.info | awk -F: '{sum += $2} END {print sum}')
            COVERED_LINES=$(grep -o "LH:[0-9]*" coverage/lcov.info | awk -F: '{sum += $2} END {print sum}')
            PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", ($COVERED_LINES/$TOTAL_LINES)*100}")

            echo ""
            echo "Coverage Summary:"
            echo "  Total lines:   $TOTAL_LINES"
            echo "  Covered lines: $COVERED_LINES"
            echo "  Coverage:      $PERCENTAGE%"
            echo ""

            # Generate HTML report
            if command -v genhtml &> /dev/null; then
                print_info "Generating HTML coverage report..."
                genhtml coverage/lcov.info -o coverage/html --quiet
                print_success "HTML report generated: coverage/html/index.html"
                echo ""
                echo "Open report: open coverage/html/index.html"
            else
                print_info "Install lcov to generate HTML reports: brew install lcov"
            fi
        fi
    else
        echo ""
        print_error "Some tests failed"
        exit 1
    fi
fi
