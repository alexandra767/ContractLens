#!/bin/bash
# ContractLens — Project Setup
# Run this on your Mac to generate the Xcode project

set -e

echo "ContractLens Project Setup"
echo "========================="

# Check for XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "Installing XcodeGen..."
    brew install xcodegen
fi

# Generate Xcode project
echo "Generating Xcode project..."
xcodegen generate

echo ""
echo "Done! Open ContractLens.xcodeproj in Xcode."
echo ""
echo "Before building:"
echo "  1. Select your Development Team in Signing & Capabilities"
echo "  2. Set your Bundle Identifier (com.yourname.contractlens)"
echo "  3. Build & run on iPhone 15 Pro or newer (required for Foundation Models)"
echo ""
echo "For StoreKit testing:"
echo "  - The scheme is already configured with the StoreKit configuration file"
echo "  - Use Xcode's StoreKit Transaction Manager to test purchases"
