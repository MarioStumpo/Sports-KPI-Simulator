#!/usr/bin/env bash
set -euo pipefail

# Resolve paths relative to this script (project root)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="sim_data_app"

PRODUCT_DIR="$SCRIPT_DIR/build/macos/Build/Products/Release"
APP_PATH="$PRODUCT_DIR/${APP_NAME}.app"
DIST_DIR="$SCRIPT_DIR/dist"
ZIP_PATH="$DIST_DIR/${APP_NAME}-macOS.zip"

echo "» Clean"
flutter clean

echo "» Ensure macOS platform"
flutter create --platforms=macos "$SCRIPT_DIR"

echo "» Build macOS (Release)"
flutter build macos --release

echo "» Prepare dist/"
mkdir -p "$DIST_DIR"

echo "» Zip .app → $ZIP_PATH"
# zip the .app bundle (must run zip from inside the Release folder)
(
  cd "$PRODUCT_DIR"
  # -y preserve symlinks, -r recurse
  zip -yr "$ZIP_PATH" "${APP_NAME}.app"
)

echo ""
echo "✔ macOS build ready:"
echo "   $ZIP_PATH"
echo "Unzip → double-click ${APP_NAME}.app (right-click → Open on first run)."
