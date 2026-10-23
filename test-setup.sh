#!/bin/bash

# Test Script - Verify Interview Setup Works
# Run this after creating the setup repo

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧪 Testing Interview Setup"
echo "=========================="
echo ""

ORIGINAL_DIR=$(pwd)

# Check if setup repo exists
SETUP_DIR="../ft-interview"
CHALLENGE_ZIP="$SETUP_DIR/interview-challenge.zip"

if [ ! -d "$SETUP_DIR" ]; then
    echo -e "${RED}❌ Setup repo not found at $SETUP_DIR${NC}"
    echo "Run ./split-repo.sh first"
    exit 1
fi

if [ ! -f "$CHALLENGE_ZIP" ]; then
    echo -e "${RED}❌ Challenge zip not found at $CHALLENGE_ZIP${NC}"
    echo "Run ./split-repo.sh first"
    exit 1
fi

echo -e "${GREEN}✅ Setup repo and challenge zip found${NC}"
echo ""

# Test 1: Setup repo structure
echo "Test 1: Checking setup repo structure..."
cd "$SETUP_DIR"

required_files=(
    "frontend/package.json"
    "makefile"
    "README.md"
    "frontend/src/App.tsx"
    "backend/models.py"
    "backend/main.py"
    "backend/database.py"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file exists"
    else
        echo -e "  ${RED}✗${NC} $file missing"
        exit 1
    fi
done

# Check that challenge-specific files are NOT in setup repo
if [ -f "DESIGN.png" ]; then
    echo -e "  ${RED}✗${NC} DESIGN.png should NOT be in setup repo"
    exit 1
else
    echo -e "  ${GREEN}✓${NC} DESIGN.png correctly excluded"
fi

if [ -f "backend/routers/pets.py" ]; then
    echo -e "  ${RED}✗${NC} pets.py should NOT be in setup repo"
    exit 1
else
    echo -e "  ${GREEN}✓${NC} pets.py correctly excluded"
fi

echo -e "${GREEN}✅ Test 1 passed: Setup repo structure correct${NC}"
echo ""

# Test 2: Challenge zip contents
echo "Test 2: Checking challenge zip contents..."

# Extract to temp directory to check contents
TEMP_DIR=$(mktemp -d)
CHALLENGE_PASSWORD=${CHALLENGE_PASSWORD:-"zendesk2026"}

echo "  Extracting zip to verify contents..."
if ! unzip -P "$CHALLENGE_PASSWORD" -q "$CHALLENGE_ZIP" -d "$TEMP_DIR" 2>/dev/null; then
    echo -e "  ${RED}✗${NC} Failed to extract zip (password may be incorrect)"
    rm -rf "$TEMP_DIR"
    exit 1
fi

challenge_files=(
    "DESIGN.png"
    "INTERVIEW_PROMPT.md"
    "backend/models.py"
    "backend/database.py"
    "backend/main.py"
    "backend/routers/pets.py"
    "backend/routers/centers.py"
    "backend/routers/applications.py"
)

for file in "${challenge_files[@]}"; do
    if [ -f "$TEMP_DIR/$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file exists in zip"
    else
        echo -e "  ${RED}✗${NC} $file missing from zip"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
done

echo -e "${GREEN}✅ Test 2 passed: Challenge zip structure correct${NC}"
echo ""

# Test 3: Check models.py content
echo "Test 3: Verifying file contents..."

cd "$SETUP_DIR"
if grep -q "class Item" backend/models.py; then
    echo -e "  ${GREEN}✓${NC} Setup repo has generic Item model"
else
    echo -e "  ${RED}✗${NC} Setup repo should have generic Item model"
    exit 1
fi

if grep -q "class Pet" "$TEMP_DIR/backend/models.py"; then
    echo -e "  ${GREEN}✓${NC} Challenge zip has Pet model"
else
    echo -e "  ${RED}✗${NC} Challenge zip should have Pet model"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Clean up temp directory
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Test 3 passed: File contents correct${NC}"
echo ""

# Test 4: Makefile commands
echo "Test 4: Checking makefile commands..."
cd "$SETUP_DIR"

if grep -q "merge-challenge:" makefile; then
    echo -e "  ${GREEN}✓${NC} merge-challenge command exists"
else
    echo -e "  ${RED}✗${NC} merge-challenge command missing"
    exit 1
fi

if grep -q "setup:" makefile; then
    echo -e "  ${GREEN}✓${NC} setup command exists"
else
    echo -e "  ${RED}✗${NC} setup command missing"
    exit 1
fi

echo -e "${GREEN}✅ Test 4 passed: Makefile commands exist${NC}"
echo ""

# Test 5: Simulate merge (on a scratch copy, so the real setup repo stays
# pristine and can be pushed without leaking the challenge)
echo "Test 5: Testing merge-challenge command..."
echo -e "${YELLOW}Note: This will actually merge files. Continue? (y/n)${NC}"
read -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Skipping merge test"
else
    SCRATCH_DIR=$(mktemp -d)/ft-interview-merge-test
    echo "  Merging in scratch copy: $SCRATCH_DIR"
    rsync -a --exclude node_modules --exclude .venv --exclude __pycache__ "$SETUP_DIR/" "$SCRATCH_DIR/"

    # Set the password and run merge
    CHALLENGE_PASSWORD=${CHALLENGE_PASSWORD:-"zendesk2026"}

    echo "Running: make merge-challenge (in scratch copy)"
    echo "Password: $CHALLENGE_PASSWORD"

    # Run merge with password piped in
    cd "$SCRATCH_DIR"
    echo "$CHALLENGE_PASSWORD" | make merge-challenge

    # Check if files were copied
    if [ -f "DESIGN.png" ]; then
        echo -e "  ${GREEN}✓${NC} DESIGN.png copied"
    else
        echo -e "  ${RED}✗${NC} DESIGN.png not copied"
        exit 1
    fi

    if [ -f "INTERVIEW_PROMPT.md" ]; then
        echo -e "  ${GREEN}✓${NC} INTERVIEW_PROMPT.md copied"
    else
        echo -e "  ${RED}✗${NC} INTERVIEW_PROMPT.md not copied"
        exit 1
    fi

    if grep -q "class Pet" backend/models.py; then
        echo -e "  ${GREEN}✓${NC} models.py replaced with Pet model"
    else
        echo -e "  ${RED}✗${NC} models.py not properly replaced"
        exit 1
    fi

    if [ -f "backend/routers/pets.py" ]; then
        echo -e "  ${GREEN}✓${NC} pets.py router copied"
    else
        echo -e "  ${RED}✗${NC} pets.py router not copied"
        exit 1
    fi

    # Clean up the scratch copy
    rm -rf "$(dirname "$SCRATCH_DIR")"
    cd "$ORIGINAL_DIR"

    echo -e "${GREEN}✅ Test 5 passed: Merge works correctly (setup repo untouched)${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 All tests passed!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "1. Test manually: cd $SETUP_DIR && make setup && make dev"
echo "2. Create GitHub repositories"
echo "3. Push both repos"
echo "4. Update email templates with repo URLs"
echo ""
