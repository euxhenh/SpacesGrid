#!/usr/bin/env bash
# create_dmg.sh — package build/SpacesGrid.app into a distributable DMG.
#
# Produces build/SpacesGrid-<version>.dmg with:
#   - SpacesGrid.app
#   - Symlink to /Applications for drag-and-drop install
#
# Usage
#   bash scripts/create_dmg.sh [version]
#   bash scripts/create_dmg.sh 1.0.0
#
# Requires: build/SpacesGrid.app to already exist (run build.sh first).
set -euo pipefail

APP_NAME="SpacesGrid"
APP_BUNDLE="build/${APP_NAME}.app"
VERSION="${1:-$(date +%Y%m%d)}"
DMG_NAME="${APP_NAME}-${VERSION}"
DMG_PATH="build/${DMG_NAME}.dmg"
STAGING="/tmp/${DMG_NAME}-staging"

# Sanity check
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: $APP_BUNDLE not found. Run 'bash build.sh' first." >&2
    exit 1
fi

echo "==> Preparing staging area..."
rm -rf "$STAGING"
mkdir -p "$STAGING"

cp -r "$APP_BUNDLE" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

echo "==> Creating DMG..."
rm -f "$DMG_PATH"
hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

rm -rf "$STAGING"

# Print SHA-256 — needed for Homebrew cask formula
SHA=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')

echo ""
echo "✓ Created: $DMG_PATH"
echo "  SHA-256: $SHA"
echo ""
echo "Attach this file to a GitHub Release, then update the Homebrew formula"
echo "at homebrew/spacesgrid.rb with the new URL and SHA-256."
