.PHONY: help setup install-frontend install-backend install-uv dev dev-frontend dev-backend check-node merge-challenge finish

help:
	@echo "Available commands:"
	@echo "  make setup           - Complete setup (check requirements + install dependencies)"
	@echo "  make merge-challenge - Merge interview challenge files (uses ./interview-challenge.zip)"
	@echo "  make dev             - Run both frontend and backend concurrently"
	@echo "  make dev-frontend    - Run frontend only"
	@echo "  make dev-backend     - Run backend only"
	@echo "  make finish          - Package completed interview for submission"

check-node:
	@echo "Checking Node.js..."
	@command -v node >/dev/null 2>&1 || { echo "❌ Node.js is not installed. Please install Node.js 18.18 or above."; exit 1; }
	@node_version=$$(node -v | cut -d'v' -f2 | cut -d'.' -f1); \
	if [ $${node_version} -lt 18 ]; then \
		echo "❌ Node.js version is too old. Please upgrade to 18.18 or above."; exit 1; \
	fi
	@echo "✅ Node.js $(node -v) detected"

install-uv:
	@echo "Checking for uv..."
	@command -v uv >/dev/null 2>&1 || { \
		echo "📦 uv not found. Installing..."; \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
		echo "✅ uv installed"; \
	} && echo "✅ uv detected"

install-frontend:
	@echo "Installing frontend dependencies..."
	cd frontend && npm install
	@echo "✅ Frontend dependencies installed"

install-backend: install-uv
	@echo "Installing backend dependencies..."
	cd backend && uv python install
	@echo "✅ Backend dependencies installed"

setup: check-node install-frontend install-backend
	@echo ""
	@echo "✅ Setup complete! Run 'make dev' to start both servers."

dev:
	@echo "Starting frontend and backend..."
	@trap 'kill 0' EXIT; \
	cd frontend && npm run dev & \
	cd backend && uv run watchfiles 'uv run main.py' & \
	wait

dev-frontend:
	cd frontend && npm run dev

dev-backend:
	cd backend && uv run watchfiles 'uv run main.py'

merge-challenge:
	@CHALLENGE_ZIP=$${CHALLENGE_ZIP:-./interview-challenge.zip}; \
	if [ ! -f "$$CHALLENGE_ZIP" ]; then \
		echo "❌ Error: Challenge zip file not found at $$CHALLENGE_ZIP"; \
		echo ""; \
		echo "Make sure interview-challenge.zip exists in the current directory."; \
		exit 1; \
	fi; \
	echo "🔄 Merging interview challenge files..."; \
	echo "📦 Extracting from: $$CHALLENGE_ZIP"; \
	echo ""; \
	read -s -p "Enter password: " PASSWORD; \
	echo ""; \
	echo ""; \
	TEMP_DIR=$$(mktemp -d); \
	if ! unzip -P "$$PASSWORD" -q "$$CHALLENGE_ZIP" -d "$$TEMP_DIR" 2>/dev/null; then \
		echo "❌ Error: Failed to extract zip file"; \
		echo "Please check the password and try again."; \
		rm -rf "$$TEMP_DIR"; \
		exit 1; \
	fi; \
	echo "📁 Copying backend files..."; \
	cp -f "$$TEMP_DIR"/backend/models.py backend/models.py; \
	cp -f "$$TEMP_DIR"/backend/database.py backend/database.py; \
	cp -f "$$TEMP_DIR"/backend/main.py backend/main.py; \
	echo "📁 Copying backend routers..."; \
	cp -rf "$$TEMP_DIR"/backend/routers/* backend/routers/; \
	echo "📁 Copying challenge documentation..."; \
	cp -f "$$TEMP_DIR"/DESIGN.png ./DESIGN.png 2>/dev/null || echo "  (DESIGN.png not found, skipping)"; \
	cp -f "$$TEMP_DIR"/INTERVIEW_PROMPT.md ./INTERVIEW_PROMPT.md; \
	rm -rf "$$TEMP_DIR"; \
	echo "🗑️  Removing challenge zip file..."; \
	rm -f "$$CHALLENGE_ZIP"; \
	echo ""; \
	echo "✅ Challenge merged successfully!"; \
	echo ""; \
	echo "📋 Next steps:"; \
	echo "  1. Read INTERVIEW_PROMPT.md for the full challenge description"; \
	echo "  2. View DESIGN.png for UI design reference"; \
	echo "  3. Run 'make dev' to start both servers"; \
	echo "  4. Start coding!"; \
	echo ""

finish:
	@echo "📦 Packaging completed interview for submission..."
	@echo ""
	@# Remove any existing challenge zip file
	@rm -f ./interview-challenge.zip
	@# Remove virtual environments and dependencies to reduce size
	@echo "🗑️  Cleaning up build artifacts..."
	@rm -rf backend/.venv backend/__pycache__ backend/routers/__pycache__
	@rm -rf frontend/node_modules frontend/dist
	@# Generate timestamp in MM_DD_YY format
	@TIMESTAMP=$$(date '+%m_%d_%y'); \
	FINISHED_ZIP="$${TIMESTAMP}_fullstack_pets.zip"; \
	echo "📁 Creating submission package: $$FINISHED_ZIP"; \
	zip -r "$$FINISHED_ZIP" . \
		-x "*.git*" \
		-x "*.DS_Store*" \
		-x "*node_modules*" \
		-x "*__pycache__*" \
		-x "*.venv*" \
		-x "*dist*" \
		-x "interview-challenge.zip"; \
	echo ""; \
	echo "✅ Interview package created: $$FINISHED_ZIP"; \
	echo ""; \
	echo "📤 Ready for submission!"; \
	echo "   Upload this zip file to your interviewer."; \
	echo ""