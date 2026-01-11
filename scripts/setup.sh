#!/bin/bash
# OXO Menus - Initial Setup Script
# This script sets up the development environment

set -e  # Exit on error

echo "🚀 OXO Menus Setup Script"
echo "=========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "ℹ $1"
}

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed"
    echo "Please install Flutter from: https://docs.flutter.dev/get-started/install"
    exit 1
else
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter is installed: $FLUTTER_VERSION"
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    print_warning "Docker is not installed"
    echo "Docker is required for running the backend. Install from: https://www.docker.com/products/docker-desktop"
else
    DOCKER_VERSION=$(docker --version)
    print_success "Docker is installed: $DOCKER_VERSION"
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose is not installed"
else
    DOCKER_COMPOSE_VERSION=$(docker-compose --version)
    print_success "Docker Compose is installed: $DOCKER_COMPOSE_VERSION"
fi

echo ""
echo "Setting up project..."
echo ""

# Install Flutter dependencies
print_info "Installing Flutter dependencies..."
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Flutter dependencies installed"
else
    print_error "Failed to install Flutter dependencies"
    exit 1
fi

# Run code generation
print_info "Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs
if [ $? -eq 0 ]; then
    print_success "Code generation completed"
else
    print_error "Code generation failed"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_info "Creating .env file from template..."
    cp .env.example .env
    print_success ".env file created"
    print_warning "Please edit .env file with your configuration"
else
    print_info ".env file already exists"
fi

# Run tests
echo ""
print_info "Running tests to verify setup..."
flutter test
if [ $? -eq 0 ]; then
    print_success "All tests passed"
else
    print_warning "Some tests failed - please review"
fi

# Check code quality
echo ""
print_info "Checking code quality..."
flutter analyze
if [ $? -eq 0 ]; then
    print_success "Code analysis passed"
else
    print_warning "Code analysis found issues - please review"
fi

echo ""
echo "========================================="
print_success "Setup completed successfully!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Edit .env file with your Directus URL"
echo "  2. Start the backend: ./scripts/start.sh"
echo "  3. Run the app: flutter run -d chrome"
echo ""
echo "For more information, see:"
echo "  - DEPLOYMENT.md (deployment guide)"
echo "  - USER_GUIDE.md (user documentation)"
echo "  - DEVELOPER_GUIDE.md (developer guide)"
echo ""
