#!/bin/bash
# Run on macOS (with Xcode / command-line tools). This is the ONLY place the
# signable main program can be produced: it compiles Source/main.swift into an
# arm64 iOS Mach-O at the CFBundleExecutable path, signs the bundle, and re-packages.
set -euo pipefail

cd "$(dirname "$0")"                 # .../AiCodeFlutterArticle.app/Source
APP="$(cd .. && pwd)"                 # .../AiCodeFlutterArticle.app
EXE="AiCodeFlutterArticle"            # must match CFBundleExecutable in Info.plist

echo "== 1/3 build main program (arm64 iOS) =="
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
echo "   iOS SDK: $SDK"
xcrun -sdk iphoneos swiftc -O -target arm64-apple-ios12.0 \
    -framework UIKit -framework WebKit \
    "$APP/Source/main.swift" -o "$APP/$EXE"
chmod +x "$APP/$EXE"
file "$APP/$EXE"   # should read: Mach-O 64-bit executable arm64

echo "== 2/3 codesign =="
# Ad-hoc (installs to a physically-connected device in dev mode):
codesign --force --deep --sign - "$APP"
# For your own device / App Store, instead use your certificate, e.g.:
#   codesign --force --deep --sign "Apple Development: you@example.com" "$APP"
#   # or "iPhone Distribution: ..." for distribution
echo "   verify:"; codesign --verify --verbose "$APP" || true

echo "== 3/3 repackage .ipa =="
cd "$(dirname "$APP")"
rm -rf Payload
mkdir Payload
cp -R "$APP" Payload/
rm -f AiCodeFlutterArticle.ipa
zip -q -X -r AiCodeFlutterArticle.ipa Payload
echo "   Wrote: $(pwd)/AiCodeFlutterArticle.ipa  (signed main program now present)"
