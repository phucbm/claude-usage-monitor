#!/bin/bash

echo "Building Claude Usage Monitor..."

mkdir -p build

APP_NAME="ClaudeUsageMonitor.app"
APP_PATH="build/$APP_NAME"

mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

cp Info.plist "$APP_PATH/Contents/"

# Generate icon if needed
if [ ! -f "ClaudeUsageMonitor.icns" ]; then
    echo "Creating app icon..."
    chmod +x make_app_icon.sh && ./make_app_icon.sh >/dev/null 2>&1
fi

if [ -f "ClaudeUsageMonitor.icns" ]; then
    cp ClaudeUsageMonitor.icns "$APP_PATH/Contents/Resources/"
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string ClaudeUsageMonitor" "$APP_PATH/Contents/Info.plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile ClaudeUsageMonitor" "$APP_PATH/Contents/Info.plist"
fi

# Copy menu bar icon PNG into bundle
if [ -f "claude-usage-monitor.png" ]; then
    cp claude-usage-monitor.png "$APP_PATH/Contents/Resources/"
fi

# Collect all Swift source files
SOURCES=$(find Sources -name "*.swift" | sort | tr '\n' ' ')

# Compile for arm64
swiftc -parse-as-library -o "$APP_PATH/Contents/MacOS/ClaudeUsageMonitor_arm64" \
    $SOURCES \
    -framework SwiftUI \
    -framework AppKit \
    -target arm64-apple-macos12.0

# Compile for x86_64
swiftc -parse-as-library -o "$APP_PATH/Contents/MacOS/ClaudeUsageMonitor_x86_64" \
    $SOURCES \
    -framework SwiftUI \
    -framework AppKit \
    -target x86_64-apple-macos12.0

# Universal binary
lipo -create -output "$APP_PATH/Contents/MacOS/ClaudeUsageMonitor" \
    "$APP_PATH/Contents/MacOS/ClaudeUsageMonitor_arm64" \
    "$APP_PATH/Contents/MacOS/ClaudeUsageMonitor_x86_64"

rm "$APP_PATH/Contents/MacOS/ClaudeUsageMonitor_arm64"
rm "$APP_PATH/Contents/MacOS/ClaudeUsageMonitor_x86_64"

echo -n "APPL????" > "$APP_PATH/Contents/PkgInfo"
chmod 755 "$APP_PATH/Contents/MacOS/ClaudeUsageMonitor"
xattr -cr "$APP_PATH"

DEVELOPER_ID="Developer ID Application: Linkko Technology Pte Ltd (Q467HQ5432)"
if codesign --force --deep --options runtime --sign "$DEVELOPER_ID" "$APP_PATH" 2>/dev/null; then
    echo "✅ Signed with Developer ID"
else
    echo "⚠️  Ad-hoc signature"
    codesign --force --deep --sign - "$APP_PATH"
fi

echo "Build successful! App: $APP_PATH"
open "$APP_PATH"
