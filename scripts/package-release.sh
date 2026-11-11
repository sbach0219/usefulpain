#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
./scripts/build-app.sh
VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' dist/usefulpain.app/Contents/Info.plist)"
ARCHIVE="dist/usefulpain-${VERSION}-arm64.zip"
ditto -c -k --sequesterRsrc --keepParent dist/usefulpain.app "$ARCHIVE"
shasum -a 256 "$ARCHIVE" > "$ARCHIVE.sha256"
echo "Packaged: $ARCHIVE"
echo "Public binary distribution still requires Developer ID signing and notarization. See docs/RELEASING.md."
