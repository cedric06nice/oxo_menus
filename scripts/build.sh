#!/bin/bash
# OXO Menus - Build Script
# Builds the application for various platforms

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

echo "🏗️  OXO Menus Build Script"
echo "========================="
echo ""

# Parse arguments
PLATFORM="web"
DIRECTUS_URL="http://localhost:8055"
RELEASE=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --directus-url)
            DIRECTUS_URL="$2"
            shift 2
            ;;
        --debug)
            RELEASE=false
            shift
            ;;
        --help)
            echo "Usage: ./scripts/build.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --platform <name>     Target platform: web, apk, appbundle, ios"
            echo "  --directus-url <url>  Directus backend URL (default: http://localhost:8055)"
            echo "  --debug               Build in debug mode (default: release)"
            echo "  --help                Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./scripts/build.sh                                    # Build web (release)"
            echo "  ./scripts/build.sh --platform apk                     # Build Android APK"
            echo "  ./scripts/build.sh --platform web --debug             # Build web (debug)"
            echo "  ./scripts/build.sh --directus-url https://api.com     # Production URL"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run code generation first
print_info "Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs
print_success "Code generation completed"

echo ""

# Build based on platform
case $PLATFORM in
    web)
        print_info "Building Flutter web app..."
        if [ "$RELEASE" = true ]; then
            flutter build web --release --dart-define=DIRECTUS_URL="$DIRECTUS_URL"
            print_success "Web app built (release mode)"
            echo ""
            echo "Output: build/web/"
            echo "Size:   $(du -sh build/web | cut -f1)"
        else
            flutter build web --dart-define=DIRECTUS_URL="$DIRECTUS_URL"
            print_success "Web app built (debug mode)"
            echo ""
            echo "Output: build/web/"
        fi
        echo ""
        echo "To serve locally:"
        echo "  cd build/web && python3 -m http.server 8000"
        ;;

    apk)
        print_info "Building Android APK..."
        if [ "$RELEASE" = true ]; then
            flutter build apk --release --dart-define=DIRECTUS_URL="$DIRECTUS_URL"
            APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
            print_success "Android APK built (release mode)"
            echo ""
            echo "Output: $APK_PATH"
            echo "Size:   $(du -sh $APK_PATH | cut -f1)"
            echo ""
            echo "To install: adb install $APK_PATH"
        else
            flutter build apk --dart-define=DIRECTUS_URL="$DIRECTUS_URL"
            APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
            print_success "Android APK built (debug mode)"
            echo ""
            echo "Output: $APK_PATH"
        fi
        ;;

    appbundle)
        print_info "Building Android App Bundle..."
        if [ "$RELEASE" = true ]; then
            flutter build appbundle --release --dart-define=DIRECTUS_URL="$DIRECTUS_URL"
            AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
            print_success "Android App Bundle built"
            echo ""
            echo "Output: $AAB_PATH"
            echo "Size:   $(du -sh $AAB_PATH | cut -f1)"
            echo ""
            echo "This bundle is ready for Google Play Store submission"
        else
            print_warning "App bundles are typically built in release mode only"
            flutter build appbundle --dart-define=DIRECTUS_URL="$DIRECTUS_URL"
        fi
        ;;

    ios)
        if [[ "$OSTYPE" != "darwin"* ]]; then
            print_warning "iOS builds require macOS"
            exit 1
        fi

        print_info "Building iOS app..."
        if [ "$RELEASE" = true ]; then
            flutter build ios --release --no-codesign --dart-define=DIRECTUS_URL="$DIRECTUS_URL"
            print_success "iOS app built (release mode, no codesign)"
            echo ""
            echo "Output: build/ios/iphoneos/"
            echo ""
            print_warning "Code signing required for device installation"
            echo "Open ios/Runner.xcworkspace in Xcode to sign and deploy"
        else
            flutter build ios --no-codesign --dart-define=DIRECTUS_URL="$DIRECTUS_URL"
            print_success "iOS app built (debug mode, no codesign)"
        fi
        ;;

    *)
        echo "Unknown platform: $PLATFORM"
        echo "Supported platforms: web, apk, appbundle, ios"
        exit 1
        ;;
esac

echo ""
print_success "Build completed successfully!"
