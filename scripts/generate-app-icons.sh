#!/bin/bash

# App Icon Generator Script
# Generates all required iOS app icon sizes from the master 1024x1024 icon

set -e

MASTER_ICON="Gorby/Assets.xcassets/AppIcon.appiconset/gorby-app-icon-black.png"
OUTPUT_DIR="Gorby/Assets.xcassets/AppIcon.appiconset"

echo "🎨 Generating app icons from master icon..."

# Check if master icon exists
if [[ ! -f "$MASTER_ICON" ]]; then
    echo "❌ Master icon not found: $MASTER_ICON"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Define all required icon sizes
declare -a SIZES=(
    "20:icon-20.png"
    "29:icon-29.png" 
    "40:icon-40.png"
    "58:icon-58.png"
    "60:icon-60.png"
    "76:icon-76.png"
    "80:icon-80.png"
    "87:icon-87.png"
    "120:icon-120.png"
    "152:icon-152.png"
    "167:icon-167.png"
    "180:icon-180.png"
)

# Generate each icon size
for size_info in "${SIZES[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    output_path="$OUTPUT_DIR/$filename"
    
    echo "  Creating ${size}x${size} -> $filename"
    sips -z "$size" "$size" "$MASTER_ICON" --out "$output_path" > /dev/null 2>&1
    
    if [[ $? -eq 0 ]]; then
        echo "  ✅ Created $filename"
    else
        echo "  ❌ Failed to create $filename"
    fi
done

echo ""
echo "🎉 App icon generation complete!"
echo "📱 All required iOS app icon sizes have been generated."
echo ""
echo "Next steps:"
echo "1. Open Xcode and verify all icons appear in the AppIcon asset"
echo "2. Build the app to ensure no missing icon warnings"
echo "3. Test on device to see the icon on home screen"