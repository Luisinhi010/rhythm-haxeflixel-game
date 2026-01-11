#!/bin/bash
# Build script for the Metadata Creator tool

echo "Building Metadata Creator..."

# Build the tool using Lime
lime build neko

if [ $? -eq 0 ]; then
    echo ""
    echo "Build successful!"
    echo ""
    echo "To run the Metadata Creator tool:"
    echo "  cd export/debug/neko/bin"
    echo "  ./MetadataCreator"
else
    echo "Build failed!"
    exit 1
fi
