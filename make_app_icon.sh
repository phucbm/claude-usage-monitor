#!/bin/bash

# Create app icon from PNG
PNG_FILE="claudeusagebar-icon.png"

if [ ! -f "$PNG_FILE" ]; then
    echo "Error: $PNG_FILE not found"
    exit 1
fi

# Create iconset directory
mkdir -p ClaudeUsageBar.iconset

# Generate all required sizes
sips -z 16 16     "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_16x16.png
sips -z 32 32     "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_16x16@2x.png
sips -z 32 32     "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_32x32.png
sips -z 64 64     "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_32x32@2x.png
sips -z 128 128   "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_128x128.png
sips -z 256 256   "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_128x128@2x.png
sips -z 256 256   "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_256x256.png
sips -z 512 512   "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_256x256@2x.png
sips -z 512 512   "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_512x512.png
sips -z 1024 1024 "$PNG_FILE" --out ClaudeUsageBar.iconset/icon_512x512@2x.png

# Convert to icns
iconutil -c icns ClaudeUsageBar.iconset

# Clean up
rm -rf ClaudeUsageBar.iconset

echo "✅ App icon created: ClaudeUsageBar.icns"
