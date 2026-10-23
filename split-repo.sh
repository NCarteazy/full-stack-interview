#!/bin/bash

# Create Setup Repo with Embedded Encrypted Challenge Zip
# Run this from your current workspace directory

set -e

echo "🚀 Creating Interview Setup Repository"
echo "======================================="
echo ""

# Get current directory
CURRENT_DIR=$(pwd)
PARENT_DIR=$(dirname "$CURRENT_DIR")

# Setup repo directory
SETUP_DIR="$PARENT_DIR/ft-interview"

echo "Current workspace: $CURRENT_DIR"
echo "Setup repo will be: $SETUP_DIR"
echo "Challenge zip will be embedded in: $SETUP_DIR/interview-challenge.zip"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# ===================================
# CREATE SETUP REPO
# ===================================

echo ""
echo "📦 Creating Setup Repository..."
echo "--------------------------------"

# Clean existing repo (preserve .git and package-lock.json if they exist)
if [ -d "$SETUP_DIR" ]; then
    echo "  Cleaning existing setup repo (preserving .git and package-lock.json)..."
    cd "$SETUP_DIR"
    # Remove everything except .git and package-lock.json
    find . -mindepth 1 -maxdepth 1 ! -name '.git' ! -name 'package-lock.json' -exec rm -rf {} +
    cd "$CURRENT_DIR"
    # Copy files into the existing directory (excluding .git)
    cp -r "$CURRENT_DIR"/* "$SETUP_DIR/"
    # Copy hidden files except .git
    for file in "$CURRENT_DIR"/.[!.]*; do
        if [ -e "$file" ] && [ "$(basename "$file")" != ".git" ]; then
            cp -r "$file" "$SETUP_DIR/"
        fi
    done
else
    # Copy entire workspace to new directory (excluding .git)
    mkdir -p "$SETUP_DIR"
    cp -r "$CURRENT_DIR"/* "$SETUP_DIR/"
    # Copy hidden files except .git
    for file in "$CURRENT_DIR"/.[!.]*; do
        if [ -e "$file" ] && [ "$(basename "$file")" != ".git" ]; then
            cp -r "$file" "$SETUP_DIR/"
        fi
    done
fi

cd "$SETUP_DIR"

# Replace backend files with generic versions
echo "  Replacing backend files with generic versions..."
cp backend/models.setup.py backend/models.py
cp backend/main.setup.py backend/main.py
cp backend/database.setup.py backend/database.py
cp README.setup.md README.md

# Replace frontend files with generic versions
echo "  Replacing frontend files with generic versions..."
cp frontend/src/App.setup.tsx frontend/src/App.tsx

# Remove challenge-specific files
echo "  Removing challenge-specific files..."
rm -f DESIGN.png
rm -f INTERVIEW_PROMPT.md
rm -f INTERVIEW_PREP_SCRIPT.md
rm -f design_image_prompt.txt
rm -f cleanup.sh
rm -f test-setup.sh
rm -f split-repo.sh
rm -f release-challenge.sh
rm -f publish.sh
rm -f backend/routers/pets.py
rm -f backend/routers/centers.py
rm -f backend/routers/applications.py

# Remove temporary files
rm -f backend/*.setup.py
rm -f README.setup.md
rm -f README.challenge.md
rm -f SETUP_REPO_PLAN.md
rm -f IMPLEMENTATION_CHECKLIST.md
rm -f frontend/src/*.setup.tsx

# Remove environment and dependency directories (should be recreated by make setup)
echo "  Removing virtual environments and dependencies..."
rm -rf backend/.venv
rm -rf frontend/node_modules
rm -rf node_modules
rm -rf .venv

# Empty the routers init file
echo "" > backend/routers/__init__.py


echo "✅ Setup repository created at: $SETUP_DIR"

# ===================================
# CREATE CHALLENGE ZIP IN SETUP REPO
# ===================================

echo ""
echo "📦 Creating Challenge Zip File..."
echo "-----------------------------------"

# Set password (can be overridden with env var)
CHALLENGE_PASSWORD=${CHALLENGE_PASSWORD:-"zendesk2026"}

# Create temporary directory for challenge files
CHALLENGE_TEMP_DIR=$(mktemp -d)

# Create directory structure
mkdir -p "$CHALLENGE_TEMP_DIR/backend/routers"

# Copy design and prompt
cp "$CURRENT_DIR/DESIGN.png" "$CHALLENGE_TEMP_DIR/"
cp "$CURRENT_DIR/INTERVIEW_PROMPT.md" "$CHALLENGE_TEMP_DIR/"

# Copy actual backend files
echo "  Copying backend challenge files..."
cp "$CURRENT_DIR/backend/models.py" "$CHALLENGE_TEMP_DIR/backend/"
cp "$CURRENT_DIR/backend/database.py" "$CHALLENGE_TEMP_DIR/backend/"
cp "$CURRENT_DIR/backend/main.py" "$CHALLENGE_TEMP_DIR/backend/"
cp "$CURRENT_DIR/backend/routers/__init__.py" "$CHALLENGE_TEMP_DIR/backend/routers/"
cp "$CURRENT_DIR/backend/routers/pets.py" "$CHALLENGE_TEMP_DIR/backend/routers/"
cp "$CURRENT_DIR/backend/routers/centers.py" "$CHALLENGE_TEMP_DIR/backend/routers/"
cp "$CURRENT_DIR/backend/routers/applications.py" "$CHALLENGE_TEMP_DIR/backend/routers/"

# Create encrypted zip inside the setup repo
CHALLENGE_ZIP="$SETUP_DIR/interview-challenge.zip"
echo "  Creating encrypted zip in setup repo..."
cd "$CHALLENGE_TEMP_DIR"
zip -r -q -P "$CHALLENGE_PASSWORD" "$CHALLENGE_ZIP" .
cd "$CURRENT_DIR"

# Clean up temp directory
rm -rf "$CHALLENGE_TEMP_DIR"

echo "✅ Challenge zip created inside setup repo"
echo "   Password: $CHALLENGE_PASSWORD"

# ===================================
# SUMMARY
# ===================================

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Setup Repository: $SETUP_DIR"
echo "  - Ready to push to GitHub"
echo "  - Contains generic boilerplate"
echo "  - Has all dependencies pre-configured"
echo "  - Includes encrypted interview-challenge.zip"
echo ""
echo "Challenge Zip Password: $CHALLENGE_PASSWORD"
echo ""
echo "Next Steps:"
echo "  1. cd $SETUP_DIR"
echo "  2. Test with: make setup && make dev"
echo "  3. Create GitHub repo and push"
echo "  4. Share repo URL + password with candidates"
echo ""
echo "Candidates will:"
echo "  1. git clone <your-repo-url>"
echo "  2. make setup"
echo "  3. make merge-challenge"
echo "  4. Enter password (you'll provide): $CHALLENGE_PASSWORD"
echo ""
echo "To clean up (delete repo):"
echo "  ./cleanup.sh"
echo ""
