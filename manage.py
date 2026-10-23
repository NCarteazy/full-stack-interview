#!/usr/bin/env python3
"""Cross-platform task runner for the FT full stack interview scaffold.

Works natively on macOS, Linux, and Windows. Requires only Python 3.13+
(via uv) — no make, bash, unzip, or zip needed.

Usage:
    uv run python manage.py <command>

Commands mirror the original Makefile targets 1:1.
"""

import argparse
import getpass
import os
import shutil
import signal
import subprocess
import sys
import time
import zipfile
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent
FRONTEND = ROOT / "frontend"
BACKEND = ROOT / "backend"
CHALLENGE_ZIP = ROOT / "interview-challenge.zip"

NODE_MIN = (20, 19)  # Vite 7 floor
BACKEND_PORT = 3001
FRONTEND_URL = "http://localhost:5173"
BACKEND_URL = f"http://localhost:{BACKEND_PORT}"

IS_WINDOWS = sys.platform == "win32"


def die(msg: str) -> None:
    print(f"❌ Error: {msg}")
    sys.exit(1)


def run(cmd: list[str], cwd: Path | None = None) -> None:
    """Run a command, streaming output, dying on failure."""
    try:
        result = subprocess.run(cmd, cwd=cwd)
    except FileNotFoundError:
        die(f"Could not find {cmd[0]!r} on your PATH.")
    if result.returncode != 0:
        sys.exit(result.returncode)


def npm_cmd() -> list[str]:
    npm = shutil.which("npm")
    if not npm:
        die(
            "npm not found. Install Node.js 20.19 or above from https://nodejs.org"
        )
    return [npm]


def check_node() -> None:
    node = shutil.which("node")
    if not node:
        die("Node.js is not installed. Please install Node.js 20.19 or above.")
    out = subprocess.run(
        [node, "-v"], capture_output=True, text=True
    ).stdout.strip()
    try:
        parts = tuple(int(p) for p in out.lstrip("v").split(".")[:2])
    except ValueError:
        die(f"Could not parse Node.js version from {out!r}.")
    if len(parts) < 2 or parts < NODE_MIN:
        print("❌ Node.js version is too old. Please upgrade to 20.19 or above.")
        sys.exit(1)
    print(f"✅ Node.js {out} detected")


def check_uv() -> list[str]:
    uv = shutil.which("uv")
    if not uv:
        print("❌ uv not found. Install it first:")
        if IS_WINDOWS:
            print("    powershell -c \"irm https://astral.sh/uv/install.ps1 | iex\"")
        else:
            print("    curl -LsSf https://astral.sh/uv/install.sh | sh")
        print("Then restart your terminal and try again.")
        sys.exit(1)
    return [uv]


# ---------------------------------------------------------------------------
# setup
# ---------------------------------------------------------------------------

def cmd_setup(_args: argparse.Namespace) -> None:
    print("Checking requirements...")
    check_node()
    uv = check_uv()

    print("\nInstalling frontend dependencies...")
    run([*npm_cmd(), "install"], cwd=FRONTEND)

    print("\nInstalling backend dependencies...")
    run([*uv, "python", "install"], cwd=BACKEND)
    run([*uv, "sync"], cwd=BACKEND)

    print("")
    print("✅ Setup complete! Run 'make dev' (or 'uv run python manage.py dev') to start both servers.")


# ---------------------------------------------------------------------------
# dev / dev-frontend / dev-backend
# ---------------------------------------------------------------------------

def _spawn(cmd: list[str], cwd: Path) -> subprocess.Popen:
    """Spawn a process in its own process group so we can kill its whole tree."""
    kwargs: dict = {}
    if IS_WINDOWS:
        kwargs["creationflags"] = subprocess.CREATE_NEW_PROCESS_GROUP
    else:
        kwargs["start_new_session"] = True
    # Drop VIRTUAL_ENV so nested `uv run` picks the right project env
    env = {k: v for k, v in os.environ.items() if k != "VIRTUAL_ENV"}
    return subprocess.Popen(cmd, cwd=cwd, env=env, **kwargs)


def _stop(proc: subprocess.Popen) -> None:
    """Terminate a process and its whole child tree."""
    if proc.poll() is not None:
        return
    try:
        if IS_WINDOWS:
            subprocess.run(
                ["taskkill", "/F", "/T", "/PID", str(proc.pid)],
                capture_output=True,
            )
        else:
            os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
            for _ in range(50):  # up to ~5s
                if proc.poll() is not None:
                    break
                time.sleep(0.1)
            if proc.poll() is None:
                os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
    except (ProcessLookupError, PermissionError):
        pass
    proc.wait()


def _backend_cmd(uv: list[str]) -> list[str]:
    """Run the backend under uvicorn's own reloader.

    uvicorn manages its reload worker itself (watchfiles under the hood),
    which restarts reliably — unlike wrapping `uv run main.py` in the
    watchfiles CLI, where the SIGINT often dies at the `uv` layer and the
    orphaned server keeps the port, so the restarted instance can't bind.
    """
    return [
        *uv,
        "run",
        "uvicorn",
        "main:app",
        "--host",
        "0.0.0.0",
        "--port",
        str(BACKEND_PORT),
        "--reload",
    ]


def cmd_dev_backend(args: argparse.Namespace) -> None:
    uv = check_uv()
    print(f"Starting backend → http://localhost:{BACKEND_PORT} (port {BACKEND_PORT}, docs at /docs)...")
    run(_backend_cmd(uv), cwd=BACKEND)


def cmd_dev_frontend(_args: argparse.Namespace) -> None:
    print(f"Starting frontend on {FRONTEND_URL}...")
    run([*npm_cmd(), "run", "dev"], cwd=FRONTEND)


def cmd_dev(_args: argparse.Namespace) -> None:
    uv = check_uv()
    print("Starting frontend and backend...", flush=True)
    print("")
    print("  ✅ Frontend → http://localhost:5173   (port 5173)", flush=True)
    print("  ✅ Backend  → http://localhost:3001   (port 3001, docs at /docs)", flush=True)
    print("", flush=True)
    print("  Press Ctrl+C to stop both.", flush=True)

    procs = [
        _spawn([*npm_cmd(), "run", "dev"], FRONTEND),
        _spawn(_backend_cmd(uv), BACKEND),
    ]
    try:
        while True:
            for proc in procs:
                code = proc.poll()
                if code is not None:
                    raise SystemExit(code)
                time.sleep(0.2)
    except KeyboardInterrupt:
        print("\nShutting down...")
    finally:
        for proc in procs:
            _stop(proc)
        print("✅ Servers stopped.")


# ---------------------------------------------------------------------------
# merge-challenge
# ---------------------------------------------------------------------------

def _read_password(args: argparse.Namespace) -> str:
    if args.password:
        return args.password
    env_pw = os.environ.get("CHALLENGE_PASSWORD")
    if env_pw:
        return env_pw
    if sys.stdin.isatty():
        return getpass.getpass("Enter password: ")
    # Piped input (e.g. test scripts): read from stdin
    return sys.stdin.readline().rstrip("\n")


def cmd_merge_challenge(args: argparse.Namespace) -> None:
    zip_path = Path(args.zip or os.environ.get("CHALLENGE_ZIP") or CHALLENGE_ZIP)
    if not zip_path.is_absolute():
        zip_path = ROOT / zip_path
    if not zip_path.is_file():
        die(
            f"Challenge zip file not found at {zip_path}\n"
            "Make sure interview-challenge.zip exists in the current directory."
        )

    password = _read_password(args).encode()
    print("🔄 Merging interview challenge files...")
    print(f"📦 Extracting from: {zip_path}")
    print("")

    merged: list[str] = []
    with zipfile.ZipFile(zip_path) as zf:
        names = [n for n in zf.namelist() if not n.endswith("/")]
        for name in names:
            dest = (ROOT / name).resolve()
            if not str(dest).startswith(str(ROOT)):
                die(f"Refusing to extract unsafe path {name!r}")
        try:
            for name in names:
                data = zf.read(name, pwd=password)
                dest = ROOT / name
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_bytes(data)
                merged.append(name)
        except (RuntimeError, zipfile.BadZipFile):
            die("Failed to extract zip file. Please check the password and try again.")

    if "INTERVIEW_PROMPT.md" not in merged:
        die("Zip is missing INTERVIEW_PROMPT.md — is this the right challenge file?")
    if not any(n.startswith("backend/routers/") for n in merged):
        die("Zip is missing backend/routers/ — is this the right challenge file?")

    zip_path.unlink()
    print(f"📁 Copied {len(merged)} files (backend, routers, docs)")
    print("🗑️  Removing challenge zip file...")
    print("")
    print("✅ Challenge merged successfully!")
    print("")
    print("📋 Next steps:")
    print("  1. Read INTERVIEW_PROMPT.md for the full challenge description")
    print("  2. View DESIGN.png for UI design reference")
    print("  3. Run 'make dev' to start both servers")
    print("  4. Start coding!")
    print("")


# ---------------------------------------------------------------------------
# finish
# ---------------------------------------------------------------------------

FINISH_EXCLUDE_DIRS = {".git", "node_modules", "__pycache__", ".venv", "dist"}
FINISH_EXCLUDE_FILES = {".DS_Store", "interview-challenge.zip"}


def cmd_finish(_args: argparse.Namespace) -> None:
    print("📦 Packaging completed interview for submission...")
    print("")
    print("🗑️  Cleaning up build artifacts...")
    for pycache in ROOT.rglob("__pycache__"):
        shutil.rmtree(pycache, ignore_errors=True)
    shutil.rmtree(BACKEND / ".venv", ignore_errors=True)
    shutil.rmtree(FRONTEND / "node_modules", ignore_errors=True)
    shutil.rmtree(FRONTEND / "dist", ignore_errors=True)
    if CHALLENGE_ZIP.exists():
        CHALLENGE_ZIP.unlink()

    timestamp = datetime.now().strftime("%m_%d_%y")
    out_name = f"{timestamp}_fullstack_pets.zip"
    out_path = ROOT / out_name
    print(f"📁 Creating submission package: {out_name}")

    with zipfile.ZipFile(out_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(ROOT.rglob("*")):
            rel = path.relative_to(ROOT)
            if path.is_dir():
                continue
            if any(part in FINISH_EXCLUDE_DIRS for part in rel.parts):
                continue
            if path.name in FINISH_EXCLUDE_FILES or path == out_path:
                continue
            zf.write(path, rel)

    print("")
    print(f"✅ Interview package created: {out_name}")
    print("")
    print("📤 Ready for submission!")
    print("   Upload this zip file to your interviewer.")
    print("")


# ---------------------------------------------------------------------------
# help / main
# ---------------------------------------------------------------------------

def cmd_help(_args: argparse.Namespace) -> None:
    print("Available commands:")
    print("  setup           - Complete setup (check requirements + install dependencies)")
    print("  dev             - Run both frontend and backend concurrently")
    print("  dev-frontend    - Run frontend only")
    print("  dev-backend     - Run backend only")
    print("  merge-challenge - Merge interview challenge files (uses ./interview-challenge.zip)")
    print("  finish          - Package completed interview for submission")
    print("")
    print("Usage: uv run python manage.py <command>")
    print("       (on macOS/Linux, 'make <command>' also works)")


def main() -> None:
    # Windows consoles may default to a non-UTF8 encoding; emoji output then raises.
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    parser = argparse.ArgumentParser(prog="manage.py", description=__doc__)
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("setup", help="Check requirements and install dependencies").set_defaults(func=cmd_setup)
    sub.add_parser("dev", help="Run both frontend and backend concurrently").set_defaults(func=cmd_dev)
    sub.add_parser("dev-frontend", help="Run frontend only").set_defaults(func=cmd_dev_frontend)
    sub.add_parser("dev-backend", help="Run backend only").set_defaults(func=cmd_dev_backend)

    p_merge = sub.add_parser("merge-challenge", help="Merge interview challenge files")
    p_merge.add_argument("--zip", help="Path to the challenge zip (default: ./interview-challenge.zip)")
    p_merge.add_argument("--password", help="Challenge password (otherwise prompted or CHALLENGE_PASSWORD env)")
    p_merge.set_defaults(func=cmd_merge_challenge)

    sub.add_parser("finish", help="Package completed interview for submission").set_defaults(func=cmd_finish)
    sub.add_parser("help", help="Show available commands").set_defaults(func=cmd_help)

    args = parser.parse_args()
    if not getattr(args, "func", None):
        cmd_help(args)
        return
    args.func(args)


if __name__ == "__main__":
    main()
