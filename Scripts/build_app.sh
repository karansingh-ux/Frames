#!/bin/bash
set -e

echo "=== Building Frames (Release) ==="
swift build -c release

BIN_PATH="$(swift build -c release --show-bin-path)/Frames"
APP_BUNDLE="build/Frames.app"

echo "=== Creating macOS App Bundle at ${APP_BUNDLE} ==="
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BIN_PATH}" "${APP_BUNDLE}/Contents/MacOS/Frames"
cp "Resources/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
fi
if [ -f "Resources/shutter.aif" ]; then
    cp "Resources/shutter.aif" "${APP_BUNDLE}/Contents/Resources/shutter.aif"
fi
if [ -f "Resources/support_illustration.png" ]; then
    cp "Resources/support_illustration.png" "${APP_BUNDLE}/Contents/Resources/support_illustration.png"
fi

echo "=== Applying Code Signature (ad-hoc with stable designated requirement) ==="
codesign --force --sign - --identifier "app.frames.macos" -r='designated => identifier "app.frames.macos"' "${APP_BUNDLE}/Contents/MacOS/Frames"
codesign --force --deep --sign - --identifier "app.frames.macos" -r='designated => identifier "app.frames.macos"' "${APP_BUNDLE}"

echo "=== Packaging Distribution Files into Export/ ==="
mkdir -p "Export"
rm -f "Export/Frames.dmg" "Export/Frames.zip"

# Create Frames.dmg
hdiutil create -volname "Frames" -srcfolder "${APP_BUNDLE}" -ov -format UDZO "Export/Frames.dmg"

# Create Frames.zip
cd build && zip -r -y -q "../Export/Frames.zip" "Frames.app" && cd ..

echo "=== Successfully Built Frames.app and Export Artifacts ==="
echo "App bundle: $(pwd)/${APP_BUNDLE}"
echo "Export files: $(pwd)/Export/"
ls -lh Export/
