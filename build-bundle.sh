#!/bin/bash

# EdgeWorkers bundle builder script
# Usage: ./build-bundle.sh

set -e

BUNDLE_NAME="doverunner_fwm_embedder"
VERSION=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${BUNDLE_NAME}_${VERSION}.tgz"

echo "=================================="
echo "EdgeWorkers Bundle Builder"
echo "=================================="
echo ""

# Check required files
echo "Checking required files..."
required_files=(
    "main.js"
    "bundle.json"
    "config.js"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file '$file' not found"
        exit 1
    fi
    echo "   ✅ $file"
done

# Check required directories
echo ""
echo "📁 Checking required directories..."
required_dirs=(
    "wmt"
    "watermark-util"
    "exception"
)

for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Error: Required directory '$dir' not found"
        exit 1
    fi
    echo "  $dir/"
done

# Create bundle
echo ""
echo "📦 Creating bundle: $OUTPUT_FILE"
COPYFILE_DISABLE=1 tar -czvf "$OUTPUT_FILE" \
    main.js \
    bundle.json \
    config.js \
    wmt/ \
    watermark-util/ \
    exception/ \
    2>&1 | sed 's/^/   /'

# Print bundle information
echo ""
echo "Bundle created successfully!"
echo ""
echo "Bundle Information:"
echo "   Name: $OUTPUT_FILE"
echo "   Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo ""

# Print bundle contents
echo "📄 Bundle Contents:"
tar -tzvf "$OUTPUT_FILE" | sed 's/^/   /'

echo ""
echo "=================================="
echo "Build Complete!"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Validate: akamai edgeworkers validate $OUTPUT_FILE"
echo "2. Upload:   akamai edgeworkers upload --bundle $OUTPUT_FILE YOUR_EW_ID"
echo ""