#!/bin/bash

# Release Challenge Script
# Creates a new version of the interview challenge zip and GitHub release
# Usage: ./release-challenge.sh [--dry-run]

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse command line arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
fi

if [[ $DRY_RUN == true ]]; then
    echo -e "${BLUE}🚀 Interview Challenge Release Script ${RED}(DRY RUN)${NC}"
    echo "=============================================="
else
    echo -e "${BLUE}🚀 Interview Challenge Release Script${NC}"
    echo "====================================="
fi
echo ""

# Check if we're in the workspace directory
if [[ ! -f "split-repo.sh" || ! -f "README.setup.md" ]]; then
    echo "❌ Error: Please run this script from the workspace directory"
    echo "   (The directory containing split-repo.sh and README.setup.md)"
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed"
    echo "   Install it from: https://cli.github.com/"
    exit 1
fi

# Get current version from README.setup.md
CURRENT_VERSION=$(grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' README.setup.md | head -1 || echo "v1.0.0")
echo -e "Current version in README.setup.md: ${YELLOW}$CURRENT_VERSION${NC}"
echo ""

# Prompt for new version
echo -e "${YELLOW}Enter new version (e.g., v1.1.0):${NC}"
read -p "> " NEW_VERSION

# Validate version format
if [[ ! $NEW_VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Error: Version must be in format vX.Y.Z (e.g., v1.1.0)"
    exit 1
fi

echo ""
echo -e "📝 Release Summary:"
echo -e "   Old version: ${YELLOW}$CURRENT_VERSION${NC}"
echo -e "   New version: ${YELLOW}$NEW_VERSION${NC}"
if [[ $DRY_RUN == true ]]; then
    echo -e "   Mode: ${RED}DRY RUN${NC} (no changes will be made)"
fi
echo ""
read -p "Continue with release? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Release cancelled."
    exit 0
fi

echo ""
if [[ $DRY_RUN == true ]]; then
    echo -e "${RED}🔄 DRY RUN - Showing commands that would be executed...${NC}"
else
    echo -e "${GREEN}🔄 Creating release...${NC}"
fi

# Step 1: Update README.setup.md with new version
echo "📝 Updating README.setup.md..."
if [[ $DRY_RUN == true ]]; then
    echo -e "${YELLOW}   Would run: sed -i.bak 's|$CURRENT_VERSION|$NEW_VERSION|g' README.setup.md${NC}"
    echo -e "${YELLOW}   Would run: rm README.setup.md.bak${NC}"
else
    sed -i.bak "s|$CURRENT_VERSION|$NEW_VERSION|g" README.setup.md
    rm README.setup.md.bak
fi

# Step 2: Create challenge zip
echo "📦 Creating challenge zip..."
CHALLENGE_PASSWORD=${CHALLENGE_PASSWORD:-"zendesk2026"}

if [[ $DRY_RUN == true ]]; then
    echo -e "${YELLOW}   Would create temporary directory for challenge files${NC}"
    echo -e "${YELLOW}   Would copy challenge files to temp directory${NC}"
    echo -e "${YELLOW}   Would run: zip -r -q -P \"$CHALLENGE_PASSWORD\" interview-challenge.zip .${NC}"
    echo -e "${YELLOW}   Would clean up temporary directory${NC}"
else
    # Create temporary directory for challenge files
    CHALLENGE_TEMP_DIR=$(mktemp -d)

    # Create directory structure
    mkdir -p "$CHALLENGE_TEMP_DIR/backend/routers"

    # Copy challenge files
    cp DESIGN.png "$CHALLENGE_TEMP_DIR/" 2>/dev/null || echo "  (DESIGN.png not found, skipping)"
    cp INTERVIEW_PROMPT.md "$CHALLENGE_TEMP_DIR/"
    cp backend/models.py "$CHALLENGE_TEMP_DIR/backend/"
    cp backend/database.py "$CHALLENGE_TEMP_DIR/backend/"
    cp backend/main.py "$CHALLENGE_TEMP_DIR/backend/"
    cp backend/routers/__init__.py "$CHALLENGE_TEMP_DIR/backend/routers/"
    cp backend/routers/pets.py "$CHALLENGE_TEMP_DIR/backend/routers/"
    cp backend/routers/centers.py "$CHALLENGE_TEMP_DIR/backend/routers/"
    cp backend/routers/applications.py "$CHALLENGE_TEMP_DIR/backend/routers/"

    # Create encrypted zip
    CHALLENGE_ZIP="interview-challenge.zip"
    CHALLENGE_ZIP_PATH="$PWD/$CHALLENGE_ZIP"
    echo "  Creating encrypted zip..."
    cd "$CHALLENGE_TEMP_DIR"
    zip -r -q -P "$CHALLENGE_PASSWORD" "$CHALLENGE_ZIP_PATH" .
    cd - > /dev/null

    # Clean up temp directory
    rm -rf "$CHALLENGE_TEMP_DIR"
fi

# Step 3: Create GitHub release
echo "🚀 Creating GitHub release..."
REPO_URL="https://github.com/NCarteazy/full-stack-interview"
if [[ $DRY_RUN == true ]]; then
    echo -e "${YELLOW}   Would run: gh release create \"$NEW_VERSION\" \"interview-challenge.zip\" \\${NC}"
    echo -e "${YELLOW}       --repo \"NCarteazy/full-stack-interview\" \\${NC}"
    echo -e "${YELLOW}       --title \"Interview Challenge Materials $NEW_VERSION\" \\${NC}"
    echo -e "${YELLOW}       --notes \"Updated interview challenge files and requirements for $NEW_VERSION\"${NC}"
    echo -e "${YELLOW}   Would run: rm interview-challenge.zip${NC}"
else
    gh release create "$NEW_VERSION" "$CHALLENGE_ZIP_PATH" \
        --repo "NCarteazy/full-stack-interview" \
        --title "Interview Challenge Materials $NEW_VERSION" \
        --notes "Updated interview challenge files and requirements for $NEW_VERSION"

    # Clean up zip file
    rm "$CHALLENGE_ZIP_PATH"
fi

echo ""
if [[ $DRY_RUN == true ]]; then
    echo -e "${YELLOW}✅ DRY RUN complete!${NC}"
    echo ""
    echo -e "${RED}📋 Commands that would have been executed:${NC}"
    echo -e "   ${YELLOW}sed -i.bak 's|$CURRENT_VERSION|$NEW_VERSION|g' README.setup.md${NC}"
    echo -e "   ${YELLOW}zip -r -q -P \"$CHALLENGE_PASSWORD\" interview-challenge.zip .${NC}"
    echo -e "   ${YELLOW}gh release create \"$NEW_VERSION\" \"interview-challenge.zip\" --repo \"NCarteazy/full-stack-interview\" [...]${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  To execute for real, run without --dry-run flag${NC}"
else
    echo -e "${GREEN}✅ Release complete!${NC}"
    echo ""
    echo -e "📋 Summary:"
    echo -e "   Version: ${YELLOW}$NEW_VERSION${NC}"
    echo -e "   Password: ${YELLOW}$CHALLENGE_PASSWORD${NC}"
    echo -e "   Download URL: https://github.com/NCarteazy/full-stack-interview/releases/download/$NEW_VERSION/interview-challenge.zip"
    echo ""
    echo -e "${YELLOW}⚠️  Don't forget to:${NC}"
    echo "   1. Update any documentation that references the old version"
    echo "   2. Test the new release by downloading and merging it with \`make merge-challenge\`"
fi
echo ""