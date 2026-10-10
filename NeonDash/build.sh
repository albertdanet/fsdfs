#!/bin/bash
# Собирает неподписанный NeonDash.ipa (для LiveContainer / AltStore / Sideloadly).
# Запускать на macOS с Xcode (в GitHub Actions: runs-on: macos-latest).
set -euo pipefail
cd "$(dirname "$0")"

APP=NeonDash
OUT=build
APPDIR="$OUT/Payload/$APP.app"

rm -rf "$OUT"
mkdir -p "$APPDIR"

SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
xcrun --sdk iphoneos swiftc -parse-as-library -O \
  -target arm64-apple-ios14.0 -sdk "$SDK" \
  AppDelegate.swift -o "$APPDIR/$APP"

cp Info.plist "$APPDIR/Info.plist"
cp index.html "$APPDIR/index.html"
printf 'APPL????' > "$APPDIR/PkgInfo"
python3 make_icon.py "$APPDIR"

file "$APPDIR/$APP"
(cd "$OUT" && zip -qry "$APP.ipa" Payload)
ls -lh "$OUT/$APP.ipa"
