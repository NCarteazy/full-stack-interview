.PHONY: help setup dev dev-frontend dev-backend merge-challenge finish

# Thin shim — the real implementation is manage.py, which works natively on
# macOS, Linux, and Windows. On Windows (no make), run commands directly:
#   uv run python manage.py <command>

help:
	@uv run python manage.py help

setup:
	@uv run python manage.py setup

dev:
	@uv run python manage.py dev

dev-frontend:
	@uv run python manage.py dev-frontend

dev-backend:
	@uv run python manage.py dev-backend

merge-challenge:
	@uv run python manage.py merge-challenge

finish:
	@uv run python manage.py finish
