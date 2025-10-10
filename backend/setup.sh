# Setup backend
# Check if uv is installed, if not, install it
command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh

uv python install
uv run watchfiles 'uv run main.py'

# Test endpoints
curl http://localhost:3001/pets
curl http://localhost:3001/centers
curl "http://localhost:3001/pets?species=cat"
