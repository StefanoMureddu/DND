#!/bin/bash

# Script to optimize images for GitHub Pages
# Usage: ./optimize-image.sh path/to/image.png [quality] [max-size]

set -e

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "❌ ImageMagick not installed. Install with: brew install imagemagick"
    exit 1
fi

# Check if file argument is provided
if [ -z "$1" ]; then
    echo "Usage: ./optimize-image.sh path/to/image.png [quality] [max-size]"
    echo ""
    echo "Examples:"
    echo "  ./optimize-image.sh docs/Maggilia/mappe/new_map.png"
    echo "  ./optimize-image.sh docs/Maggilia/mappe/new_map.png 90 4000"
    echo ""
    echo "Defaults: quality=85, max-size=3000"
    exit 1
fi

INPUT_FILE="$1"
QUALITY="${2:-85}"
MAX_SIZE="${3:-3000}"

# Check if file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ File not found: $INPUT_FILE"
    exit 1
fi

# Get file info
FILE_DIR=$(dirname "$INPUT_FILE")
FILE_NAME=$(basename "$INPUT_FILE")
FILE_BASE="${FILE_NAME%.*}"
FILE_EXT="${FILE_NAME##*.}"

# Generate output filename
OUTPUT_FILE="${FILE_DIR}/${FILE_BASE}_web.jpg"

# Check file size
FILE_SIZE=$(du -h "$INPUT_FILE" | cut -f1)
echo "📁 Input file: $INPUT_FILE ($FILE_SIZE)"

# Optimize the image
echo "🔄 Optimizing image..."
echo "   Quality: $QUALITY%"
echo "   Max dimensions: ${MAX_SIZE}x${MAX_SIZE}"

magick "$INPUT_FILE" \
    -strip \
    -resize "${MAX_SIZE}x${MAX_SIZE}>" \
    -quality "$QUALITY" \
    "$OUTPUT_FILE"

# Show results
OUTPUT_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
echo "✅ Created: $OUTPUT_FILE ($OUTPUT_SIZE)"

# Calculate savings
INPUT_BYTES=$(stat -f%z "$INPUT_FILE" 2>/dev/null || stat -c%s "$INPUT_FILE" 2>/dev/null)
OUTPUT_BYTES=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
SAVINGS=$(echo "scale=1; (1 - $OUTPUT_BYTES / $INPUT_BYTES) * 100" | bc)

echo "💾 Size reduced by ${SAVINGS}%"
echo ""
echo "Next steps:"
echo "  1. Review the optimized image: open '$OUTPUT_FILE'"
echo "  2. Add to git: git add '$OUTPUT_FILE'"
echo "  3. Update your markdown to link: [$FILE_BASE]($OUTPUT_FILE)"
echo "  4. Commit: git commit -m 'Add optimized $FILE_BASE'"
echo "  5. Push: git push"
