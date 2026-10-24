#!/usr/bin/env bash
# Build the Piano iPad/iPhone app on a Mac and upload it to TestFlight.
#
#   scripts/testflight.sh <TEAM_ID>            build, then upload
#   scripts/testflight.sh <TEAM_ID> --no-upload  build and archive only
#
# Needs: Xcode, XcodeGen (brew install xcodegen), and an Apple account signed
# in to Xcode > Settings > Accounts. Signing is automatic. The team ID is an
# argument so that it stays out of this public repo.
set -euo pipefail

TEAM_ID="${1:?usage: scripts/testflight.sh <TEAM_ID> [--no-upload]}"
if ! [[ "$TEAM_ID" =~ ^[A-Z0-9]{10}$ ]]; then
  echo "Give the 10-character Apple team ID, for example ABCDE12345." >&2
  exit 2
fi
# Refuse an unknown flag: a typo of --no-upload must not upload.
case "${2:-}" in
  "") UPLOAD=1 ;;
  --no-upload) UPLOAD=0 ;;
  *) echo "Unknown option: $2. Use --no-upload or nothing." >&2; exit 2 ;;
esac

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Build outside the repo. A repo under ~/Desktop can sync to iCloud, and iCloud
# adds file attributes that make codesign fail ("detritus not allowed").
CACHE="$HOME/Library/Caches/piano-build"
BUILD="$CACHE/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BUILD"

echo "== PianoCore tests"
swift test --package-path "$ROOT/PianoCore" --scratch-path "$CACHE/spm"

echo "== Xcode project"
(cd "$ROOT/App" && xcodegen generate)

echo "== Archive"
xcodebuild archive \
  -project "$ROOT/App/Piano.xcodeproj" \
  -scheme Piano \
  -destination "generic/platform=iOS" \
  -archivePath "$BUILD/Piano.xcarchive" \
  -derivedDataPath "$CACHE/DerivedData" \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  | tail -n 20

if [[ "$UPLOAD" == 0 ]]; then
  echo "== Archive done, upload skipped: $BUILD/Piano.xcarchive"
  exit 0
fi

echo "== Export and upload to App Store Connect"
OPTIONS="$BUILD/ExportOptions.plist"
cp "$ROOT/scripts/ExportOptions.plist" "$OPTIONS"
/usr/libexec/PlistBuddy -c "Add :teamID string $TEAM_ID" "$OPTIONS"
xcodebuild -exportArchive \
  -archivePath "$BUILD/Piano.xcarchive" \
  -exportOptionsPlist "$OPTIONS" \
  -exportPath "$BUILD/export" \
  -allowProvisioningUpdates \
  | tail -n 20

echo "== Uploaded. The build shows in App Store Connect > TestFlight after Apple processes it."
