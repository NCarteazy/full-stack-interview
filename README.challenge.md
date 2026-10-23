# Interview Challenge Contents

Reference for what ships inside the encrypted `interview-challenge.zip`
(published via GitHub Releases by `release-challenge.sh`).

## Merging Instructions (candidate side)

From the cloned `ft-interview` setup directory:

```bash
make merge-challenge                        # macOS/Linux
uv run python manage.py merge-challenge     # any platform
```

Enter the password when prompted. The zip must be at
`./interview-challenge.zip` in the setup directory (the README's curl
command downloads it there), and the merge deletes it after extracting.

## What's in the Zip?

- `INTERVIEW_PROMPT.md` - Full challenge description and requirements
- `DESIGN.png` - UI design reference
- `backend/` - Complete backend implementation files:
  - `models.py` - Data models for the challenge
  - `database.py` - Pre-seeded database with test data
  - `main.py` - FastAPI application with all routes configured
  - `routers/` - API endpoint implementations

## Troubleshooting

### "Failed to extract zip file"
The password was wrong. Ask the interviewer to resend it.

### Files Not Copying
Check that you have write permissions in the setup directory.

## Questions?

If something isn't working, please let your interviewer know immediately. We want you to spend your time coding, not debugging the setup!

---

**Time starts after you successfully merge and start the dev servers. Good luck! 🚀**
