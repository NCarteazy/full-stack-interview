# Forethought Technologies - Interview Setup

Welcome! Please complete this setup **before** your scheduled interview.

## Pre-Interview Setup

### 1. Prerequisites

Install these if you don't have them:
- **Node.js** 18.18+ ([Download](https://nodejs.org/))
- **Git**
- **uv** Python package manager:
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```
  Restart your terminal after installation.

### 2. Clone and Setup

```bash
git clone https://github.com/NCarteazy/full-stack-interview.git ft-interview
cd ft-interview
make setup
```

### 3. Verify Everything Works

```bash
make dev
```

Visit `http://localhost:5173` in your browser. You should see a confirmation page.

Press `Ctrl+C` to stop the servers.

### 4. Download the Challenge

Download the challenge zip file from GitHub releases:

```bash
curl -L -o interview-challenge.zip https://github.com/NCarteazy/full-stack-interview/releases/download/v1.0.0/interview-challenge.zip
```

Or download it manually from: https://github.com/NCarteazy/full-stack-interview/releases

You'll be given a password to unlock it later.


## During Your Interview

You'll receive the password for the encrypted challenge file.

### Merge the Challenge

```bash
make merge-challenge
```

You'll be prompted for the password (provided by your interviewer).

This will extract and merge all challenge files into your setup.

### Start Coding!

```bash
make dev
```

Read `INTERVIEW_PROMPT.md` for the full challenge description.

## Troubleshooting

**uv not found?**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# Restart your terminal
```

**Node version too old?**  
Update to 18.18+ from [nodejs.org](https://nodejs.org/). You can use a node version manager like `nvm` or `fnm` to install multiple Node Versions at once.

**Other issues?**  
Contact your interview coordinator.

## Questions?

If you have any issues with setup, reach out to your interview coordinator.

Good luck! 🚀
