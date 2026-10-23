#!/bin/bash

# Cleanup Script - Remove Setup Repository
# This script removes ft-interview repo
# Run from anywhere to clean up after testing

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧹 Interview Repository Cleanup"
echo "================================"
echo ""
echo "This will delete ft-interview repo."
echo ""
echo -e "${YELLOW}Are you sure you want to cleanup? (y/N)${NC}"
read -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Determine where we're running from
CURRENT_DIR=$(pwd)
PARENT_DIR=$(dirname "$CURRENT_DIR")

# Check if we're in the setup repo
if [[ "$CURRENT_DIR" == *"ft-interview"* ]]; then
    SETUP_DIR="$CURRENT_DIR"
    cd "$PARENT_DIR"
else
    # We're in workspace directory, ft-interview is in parent
    SETUP_DIR="$PARENT_DIR/ft-interview"
fi

echo "Looking for setup repo at: $SETUP_DIR"

# Delete setup repo contents (preserving .git)
if [ -d "$SETUP_DIR" ]; then
    cd "$SETUP_DIR"
    echo -e "${GREEN}✓${NC} Cleaning ft-interview at $SETUP_DIR"
    # Remove everything except .git
    find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
    echo -e "${GREEN}✓${NC} Cleaned ft-interview contents (preserved .git)"
else
    echo -e "${YELLOW}!${NC} ft-interview directory not found at $SETUP_DIR"
fi

echo ""
echo -e "${GREEN}✅ Cleanup complete!${NC}"
