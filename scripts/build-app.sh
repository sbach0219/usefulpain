#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "usefulpain requires macOS 14 or newer and Apple's Swift toolchain." >&2
  exit 1
fi
CONFIGURATION="${CONFIGURATION:-release}"
if [[ "$CONFIGURATION" != "release" && "$CONFIGURATION" != "debug" ]]; then
  echo "CONFIGURATION must be release or debug." >&2
  exit 1
fi
swift build -c "$CONFIGURATION" --arch arm64
BIN_DIR="$(swift build -c "$CONFIGURATION" --arch arm64 --show-bin-path)"
BUILD_DIR="$(mktemp -d "$ROOT/.build/usefulpain-bundle.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT
APP="$BUILD_DIR/usefulpain.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$ROOT/dist"
cp "$BIN_DIR/usefulpain" "$APP/Contents/MacOS/usefulpain"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"
xcrun swift "$ROOT/scripts/make-icon.swift" "$BUILD_DIR/AppIcon.iconset"
xcrun iconutil --convert icns "$BUILD_DIR/AppIcon.iconset" --output "$APP/Contents/Resources/AppIcon.icns"
SIGNING_IDENTITY="${CODE_SIGN_IDENTITY:--}"
if [[ "$SIGNING_IDENTITY" == "-" ]]; then
  codesign --force --sign - "$APP"
else
  codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP"
fi
codesign --verify --deep --strict "$APP"
/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Contents/Info.plist" >/dev/null
if [[ "$(lipo -archs "$APP/Contents/MacOS/usefulpain")" != "arm64" ]]; then
  echo "Expected an Apple Silicon-only arm64 binary." >&2
  exit 1
fi
# Replace only this script's generated app bundle, never user files.
rm -rf "$ROOT/dist/usefulpain.app"
mv "$APP" "$ROOT/dist/usefulpain.app"
echo "Built: $ROOT/dist/usefulpain.app (arm64)"
