#!/bin/bash

# One-command publish pipeline for the interview challenge.
# Usage: ./publish.sh <version> [--dry-run]
#   e.g. ./publish.sh v1.2.0
#
# Order matters: the version is bumped FIRST, so the regenerated setup
# repo already carries it, and the GitHub release (created LAST, after
# the public repo push) tags the freshly-pushed commit instead of a
# stale one.

set -e

if [[ ! -f "split-repo.sh" || ! -f "README.setup.md" ]]; then
    echo "❌ Run this from the workspace directory (the one with split-repo.sh)"
    exit 1
fi

VERSION="$1"
if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Usage: ./publish.sh <version> [--dry-run]   e.g. ./publish.sh v1.2.0"
    exit 1
fi
DRY_RUN=""
if [[ "$2" == "--dry-run" ]]; then
    DRY_RUN=" (dry run)"
fi

PUBLIC_DIR="$(dirname "$PWD")/full-stack-interview"
if [[ ! -d "$PUBLIC_DIR/.git" ]]; then
    echo "❌ Public repo not found at $PUBLIC_DIR"
    echo "   Clone it first: gh repo clone NCarteazy/full-stack-interview $PUBLIC_DIR"
    exit 1
fi

echo "🚀 Publishing challenge $VERSION$DRY_RUN"
echo "   Setup repo:  ../ft-interview"
echo "   Public repo: $PUBLIC_DIR"
echo ""

run() {
    echo "▶ $*"
    if [[ -z "$DRY_RUN" ]]; then "$@"; fi
}

# 0. Bump the version in README.setup.md now, so everything downstream
# (setup repo, public repo) carries it. Idempotent.
OLD_VERSION=$(grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' README.setup.md | head -1 || true)
if [[ -n "$OLD_VERSION" && "$OLD_VERSION" != "$VERSION" ]]; then
    run sed -i.bak "s|$OLD_VERSION|$VERSION|g" README.setup.md
    if [[ -z "$DRY_RUN" ]]; then rm -f README.setup.md.bak; fi
fi

# 1. Regenerate setup repo + 2. Test it (Test 5 merges in a scratch copy,
# so ft-interview stays push-safe)
run bash -c 'echo y | ./split-repo.sh'
run bash -c 'echo y | ./test-setup.sh'

# 3. Sync the public repo and push (so the release tags THIS commit)
echo "▶ Syncing public repo..."
if [[ -z "$DRY_RUN" ]]; then
    rsync -a --delete \
        --exclude .git --exclude interview-challenge.zip \
        --exclude .venv --exclude node_modules \
        "$(pwd)/" "$PUBLIC_DIR/"
    cd "$PUBLIC_DIR"
    if [[ -n "$(git status --porcelain)" ]]; then
        git add -A
        git commit -m "Publish challenge $VERSION"
        git push origin main
        echo "✅ Pushed public repo"
    else
        echo "ℹ️  Public repo already up to date"
    fi
    cd - > /dev/null
fi

# 4. Release the challenge zip — created last, so the tag lands on the
# freshly-pushed public repo HEAD. (Its own version sed is a no-op here.)
run bash -c "printf '$VERSION\ny\n' | ./release-challenge.sh"

echo ""
echo "🎉 Challenge $VERSION published$DRY_RUN"
echo "   Zip password: ${CHALLENGE_PASSWORD:-zendesk2026} (see split-repo.sh)"
