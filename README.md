# Forethought Technologies - Interview Setup

Welcome! Please complete this setup **before** your scheduled interview.

## Pre-Interview Setup

### 1. Prerequisites

Install these if you don't have them:
- **Node.js** 20.19+ (an LTS version like 22 is recommended) ([Download](https://nodejs.org/))
- **Git**
- **uv** Python package manager:
  - macOS / Linux:
    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```
  - Windows (PowerShell):
    ```powershell
    powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
    ```

  Restart your terminal after installation.

### 2. Clone and Setup

**macOS / Linux:**
```bash
git clone https://github.com/NCarteazy/full-stack-interview.git ft-interview
cd ft-interview
make setup
```

**Windows (or anywhere without `make`):**
```powershell
git clone https://github.com/NCarteazy/full-stack-interview.git ft-interview
cd ft-interview
uv run python manage.py setup
```

### 3. Verify Everything Works

**macOS / Linux:** `make dev` — **Windows:** `uv run python manage.py dev`

Visit `http://localhost:5173` in your browser. You should see a confirmation page.

Press `Ctrl+C` to stop the servers.

### 4. Download the Challenge

Download the latest challenge zip file from GitHub releases:

```bash
curl -L -o interview-challenge.zip https://github.com/NCarteazy/full-stack-interview/releases/download/v1.1.0/interview-challenge.zip
```

Or download it manually from: https://github.com/NCarteazy/full-stack-interview/releases

You'll be given a password to unlock it later.


## During Your Interview

You'll receive the password for the encrypted challenge file.

### Merge the Challenge

**macOS / Linux:**
```bash
make merge-challenge
```

**Windows:**
```powershell
uv run python manage.py merge-challenge
```

You'll be prompted for the password (provided by your interviewer).

This will extract and merge all challenge files into your setup.

### Start Coding!

**macOS / Linux:** `make dev` — **Windows:** `uv run python manage.py dev`

Read `INTERVIEW_PROMPT.md` for the full challenge description.

## Troubleshooting

**uv not found?**
- macOS / Linux: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Windows (PowerShell): `powershell -c "irm https://astral.sh/uv/install.ps1 | iex"`
- Restart your terminal after installing.

**Node version too old?**
Update to 20.19+ from [nodejs.org](https://nodejs.org/). You can use a node version manager like `nvm`, `fnm`, or `nvm-windows` to install multiple Node versions at once.

**`make: command not found` (macOS/Linux)?**
Use the `uv run python manage.py <command>` form instead — everything works without make.

**Other issues?**
Contact your interview coordinator.

## Questions?

If you have any issues with setup, reach out to your interview coordinator.

Good luck! 🚀
