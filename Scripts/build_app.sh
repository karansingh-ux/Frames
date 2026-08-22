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
mkdir -p "${APP_BUNDLE}/Contents/Frameworks"

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

# Copy Sparkle.framework into Frameworks
SPARKLE_FRAMEWORK=$(find .build -name "Sparkle.framework" 2>/dev/null | grep "macos" | head -n 1)
if [ -n "${SPARKLE_FRAMEWORK}" ] && [ -d "${SPARKLE_FRAMEWORK}" ]; then
    cp -R "${SPARKLE_FRAMEWORK}" "${APP_BUNDLE}/Contents/Frameworks/Sparkle.framework"
    echo "Embedded Sparkle.framework into App Bundle"
fi

# Add Frameworks RPATH
install_name_tool -add_rpath "@executable_path/../Frameworks" "${APP_BUNDLE}/Contents/MacOS/Frames" 2>/dev/null || true

echo "=== Applying Code Signature (ad-hoc with stable designated requirement) ==="
if [ -d "${APP_BUNDLE}/Contents/Frameworks/Sparkle.framework" ]; then
    codesign --force --sign - --identifier "org.sparkle-project.Sparkle" "${APP_BUNDLE}/Contents/Frameworks/Sparkle.framework"
fi
codesign --force --sign - --identifier "app.frames.macos" -r='designated => identifier "app.frames.macos"' "${APP_BUNDLE}/Contents/MacOS/Frames"
codesign --force --deep --sign - --identifier "app.frames.macos" -r='designated => identifier "app.frames.macos"' "${APP_BUNDLE}"

echo "=== Packaging Distribution Files into Export/ ==="
mkdir -p "Export"
rm -f "Export/Frames.dmg" "Export/Frames.zip" "Export/appcast.xml"

# Create Frames.dmg
hdiutil create -volname "Frames" -srcfolder "${APP_BUNDLE}" -ov -format UDZO "Export/Frames.dmg"

# Create Frames.zip for Sparkle Updates
cd build && zip -r -y -q "../Export/Frames.zip" "Frames.app" && cd ..

# Sync with Website downloads folder if present
if [ -d "website/public" ]; then
    mkdir -p "website/public/downloads"
    cp "Export/Frames.dmg" "website/public/downloads/Frames.dmg"
    cp "Export/Frames.zip" "website/public/downloads/Frames.zip"
    echo "Synced Export artifacts -> website/public/downloads/"
fi

# Generate and sign Sparkle AppCast
echo "=== Generating Sparkle AppCast Feed ==="
swift "Scripts/generate_appcast.swift"

echo "=== Successfully Built Frames.app and Export Artifacts ==="
echo "App bundle: $(pwd)/${APP_BUNDLE}"
echo "Export files: $(pwd)/Export/"
ls -lh Export/
