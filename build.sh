#!/usr/bin/env bash
# build.sh — compile SpacesGrid and package it as a signed .app bundle.
#
# Usage
#   bash build.sh             # native architecture (arm64 or x86_64)
#   bash build.sh --universal # fat binary: arm64 + x86_64 via lipo
set -euo pipefail

APP_NAME="SpacesGrid"
BUILD_DIR="$(pwd)/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
MACOS_DIR="$APP_BUNDLE/Contents/MacOS"
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"

# Parse flags
UNIVERSAL=false
for arg in "$@"; do
    case "$arg" in
        --universal) UNIVERSAL=true ;;
        *) echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

SOURCES=(
    Sources/main.swift
    Sources/CGSPrivate.swift
    Sources/Preferences.swift
    Sources/PreferencesView.swift
    Sources/SpacesManager.swift
    Sources/GridView.swift
    Sources/AppDelegate.swift
)

# ---------------------------------------------------------------------------
# Clean
# ---------------------------------------------------------------------------

echo "==> Cleaning previous build..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# ---------------------------------------------------------------------------
# Compile
# ---------------------------------------------------------------------------

compile() {
    local target="$1"
    local output="$2"
    swiftc \
        "${SOURCES[@]}" \
        -framework Cocoa \
        -target "$target" \
        -O \
        -o "$output"
}

if $UNIVERSAL; then
    echo "==> Compiling for arm64..."
    compile "arm64-apple-macos13.0"  "$MACOS_DIR/${APP_NAME}_arm64"

    echo "==> Compiling for x86_64..."
    compile "x86_64-apple-macos13.0" "$MACOS_DIR/${APP_NAME}_x86_64"

    echo "==> Creating universal binary with lipo..."
    lipo -create \
        "$MACOS_DIR/${APP_NAME}_arm64" \
        "$MACOS_DIR/${APP_NAME}_x86_64" \
        -output "$MACOS_DIR/$APP_NAME"
    rm "$MACOS_DIR/${APP_NAME}_arm64" "$MACOS_DIR/${APP_NAME}_x86_64"
else
    ARCH=$(uname -m)
    TARGET="${ARCH}-apple-macos13.0"
    echo "==> Compiling Swift sources (${ARCH})..."
    compile "$TARGET" "$MACOS_DIR/$APP_NAME"
fi

# ---------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------

echo "==> Copying resources..."
cp Resources/Info.plist "$APP_BUNDLE/Contents/Info.plist"

if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns "$RESOURCES_DIR/AppIcon.icns"
fi

# ---------------------------------------------------------------------------
# Ad-hoc code signing (required on Apple Silicon even for local builds)
# ---------------------------------------------------------------------------

echo "==> Ad-hoc code signing..."
codesign --force --deep --sign - "$APP_BUNDLE"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

LABEL="native ($(uname -m))"
$UNIVERSAL && LABEL="universal (arm64 + x86_64)"

echo ""
echo "✓ Built [$LABEL]: $APP_BUNDLE"
echo ""
echo "  Run:     open \"$APP_BUNDLE\""
echo "  Install: cp -r \"$APP_BUNDLE\" /Applications/"
