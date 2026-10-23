# Pet Adoption Center - Interview Challenge

This repository contains a full-stack interview challenge that creates a setup repository with an encrypted challenge file.

## Quick Start

```bash
./split-repo.sh        # Creates setup repo with embedded challenge
./test-setup.sh        # Validates everything works
./cleanup.sh           # Cleans setup repo (preserves .git)
./release-challenge.sh # Packages and releases a new .zip of challenge contents
```

## Cross-Platform Candidate Flow

All candidate-facing commands are implemented in **`manage.py`** (Python
stdlib only), so they work natively on macOS, Linux, and Windows. The
`makefile` is a thin shim that delegates to it for macOS/Linux users.

```bash
uv run python manage.py setup           # check requirements + install everything
uv run python manage.py dev             # frontend + backend concurrently
uv run python manage.py dev-frontend    # frontend only
uv run python manage.py dev-backend     # backend only
uv run python manage.py merge-challenge # extract challenge zip into the repo
uv run python manage.py finish          # timestamped submission zip
```

Each is also available as `make <command>` on macOS/Linux.

Implementation notes:
- `dev` runs the backend via `uv run uvicorn main:app --reload` — uvicorn's
  own reloader manages the worker process, which restarts reliably. (The old
  `watchfiles 'uv run main.py'` setup lost the restart signal at the `uv`
  layer, leaving an orphaned server holding the port.)
- `merge-challenge` extracts the encrypted zip with Python's stdlib `zipfile`
  (ZipCrypto, produced by `zip -P` in the scripts below) — no `unzip`
  binary needed, which never existed on stock Windows.
- `finish` builds the submission zip with stdlib `zipfile` — no `zip`
  binary needed.

## How It Works

### Setup Repository Strategy:

1. **[ft-interview](https://github.com/NCarteazy/full-stack-interview)**
   - Candidates clone and install dependencies **before** interview
   - Contains generic boilerplate (no hints about pets)
   - All dependencies pre-configured
   - Challenge zip available via GitHub releases

### Interview Flow:

**Before Interview (Candidate does at home):**
```bash
git clone https://github.com/NCarteazy/full-stack-interview.git ft-interview
cd ft-interview
make setup    # or: uv run python manage.py setup
make dev      # verifies it works

# Download challenge file for later
curl -L -o interview-challenge.zip https://github.com/NCarteazy/full-stack-interview/releases/download/v1.0.0/interview-challenge.zip
```

**During Interview (Takes 20 seconds):**
```bash
# Merge challenge with password (provided by interviewer)
make merge-challenge
# Enter password when prompted

# Start coding
make dev

# When finished
make finish   # Creates timestamped submission zip
```

## File Organization

This repo uses `.setup.` naming for setup versions:

```
workspace/
├── manage.py                # Cross-platform task runner (the real implementation)
├── pyproject.toml           # Root project so `uv run` works from the repo root
├── makefile                 # Thin shim delegating to manage.py
├── frontend/
│   ├── src/
│   │   ├── App.tsx          # Real: Pet adoption interface
│   │   └── App.setup.tsx    # Setup: Generic welcome page
│   ├── package.json
│   ├── package-lock.json
│   ├── eslint.config.js     # Flat config (ESLint 10)
│   └── ...config files
└── backend/
    ├── models.py            # Real: Pet, Center, Application
    ├── models.setup.py      # Setup: Generic Item, Category
    ├── main.py              # Real: Full FastAPI with routers
    ├── main.setup.py        # Setup: Basic health check
    ├── database.py          # Real: Pet data seeded
    └── database.setup.py    # Setup: Generic sample data
```

Maintainer-only files (never shipped to candidates): `DESIGN.png`,
`INTERVIEW_PROMPT.md` (these ship inside the encrypted zip),
`design_image_prompt.txt` (prompt used to regenerate DESIGN.png), and the
`*.sh` scripts.

The `split-repo.sh` script copies `.setup.` files over real ones for the setup repo.

## Deploy to GitHub

After running `./split-repo.sh`, push the setup repo:

```bash
cd ../ft-interview
git add . && git commit -m "Setup repository"
git remote add origin <your-setup-repo-url>
git push -u origin main
```

## Available Commands

- `setup` - Install all dependencies
- `dev` - Run frontend + backend concurrently
- `merge-challenge` - Extract and merge challenge files
- `finish` - Create timestamped submission zip

(`make <command>` on macOS/Linux, `uv run python manage.py <command>` everywhere.)

## Release New Challenge Version

To release a new version of the interview challenge:

```bash
./release-challenge.sh    # Interactive script that handles everything
```

This script will:
- Prompt for the new version number
- Update README.setup.md with the new version
- Create the challenge zip file
- Create a GitHub release with the zip

## Cleanup (Testing)

To clean the ft-interview repository while preserving .git:

```bash
./cleanup.sh    # Removes all files except .git
```

This preserves the Git repository for repeated testing of the split/merge process.

---

**That's it!** The scripts handle everything. Just run `./split-repo.sh` and you're ready.
