#!/bin/bash

# Development environment setup script for pyesi-client
# This script sets up all necessary tools for development including:
# - Python dependencies with uv (replaces poetry/pip)
# - Git hooks with lefthook (includes commitlint)
# - Code quality tools: ruff (replaces flake8/black), ty (replaces mypy/pyright)
# - Testing with pytest and coverage <- No pytest for now, will add later if necessary

set -e

echo "🚀 Setting up development environment for pyesi-client..."

# Check if we're in the right directory
if [ ! -f "pyproject.toml" ]; then
    echo "❌ Error: This script must be run from the project root directory"
    exit 1
fi

# Check for required environment files
if [ ! -f ".env.example" ]; then
    echo "⚠️  Warning: .env.example file not found"
fi

# Install Python dependencies with uv
echo "📦 Installing Python dependencies with uv..."
if ! command -v uv >/dev/null 2>&1; then
    echo "❌ Error: uv is not installed. Please install uv first."
    echo "   Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "   Or visit: https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
fi

# Check Python version
if [ ! -f ".python-version" ]; then
    echo "3.14" > .python-version
    echo "📝 Created .python-version file with Python 3.14"
fi

# Install lefthook and sync hooks
echo "🪝 Setting up lefthook for Git hooks..."
uv run lefthook install
echo "✅ Added lefthook config and synced Git hooks"

# Sync dependencies including dev extras
uv sync --all-extras --dev
echo "✅ Python dependencies installed with uv"

# !!!MIGRATING TO LEFTHOOK!!!
# Initialize pre-commit hooks (includes commitlint for commit-msg validation)
# echo "🪝 Setting up pre-commit hooks..."
# uv run pre-commit install
# uv run pre-commit install --hook-type pre-commit
# uv run pre-commit install --hook-type commit-msg
# uv run pre-commit run --all-files
# echo "✅ Pre-commit hooks installed (includes commitlint for commit messages)"

# Create environment file if it doesn't exist
if [ ! -f ".env.development" ] && [ -f ".env.example" ]; then
    cp .env.example .env.development
    echo "📄 Copied .env.example to .env.development"
fi

# Run verification tests
echo "🧪 Running verification tests..."

# Test ruff linting and formatting
echo "  Testing ruff linting..."
if uv run ruff check --quiet .; then
    echo "  ✅ Ruff linting passed"
else
    echo "  ⚠️  Ruff found linting issues (run 'uv run ruff check --fix .' to auto-fix)"
fi

echo "  Testing ruff formatting..."
if uv run ruff format --check --quiet .; then
    echo "  ✅ Ruff formatting passed"
else
    echo "  ⚠️  Ruff found formatting issues (run 'uv run ruff format .' to format)"
fi

echo "  Testing ty type checking..."
if uv run ty check; then
    echo "  ✅ Ty type checking passed"
else
    echo "  ⚠️  Ty found type issues (this is normal for initial setup)"
fi

# # Test pytest if tests directory exists
# if [ -d "tests" ] && [ "$(find tests -name '*.py' | head -1)" ]; then
#     echo "  Testing pytest..."
#     if uv run pytest --quiet --tb=no; then
#         echo "  ✅ Tests passed"
#     else
#         echo "  ⚠️  Some tests failed (run 'uv run pytest -v' for details)"
#     fi
# else
#     echo "  ⚠️  No tests found in tests/ directory"
# fi

echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "🛠️  Available development commands:"
# echo "  uv run pytest                    # Run tests"
# echo "  uv run pytest --cov              # Run tests with coverage report"
# echo "  uv run pytest --cov --cov-report=html  # Generate HTML coverage report"
echo "  uv run ruff check                # Run linting"
echo "  uv run ruff check --fix          # Run linting with auto-fix"
echo "  uv run ruff format               # Format code"
# !!!MIGRATING TO TY!!!
# echo "  uv run --with pyrefly pyrefly check  # Run type checking"
echo "  uv run ty check                  # Run type checking with Ty"
# !!!MIGRATING TO LEFTHOOK!!!
# echo "  uv run pre-commit run --all-files  # Run all pre-commit hooks manually"
echo "  uv run lefthook run pre-commit  # Run pre-commit hooks manually"
echo ""
echo "📁 Project structure:"
echo "  - Dependencies managed by: uv (pyproject.toml)"
echo "  - Code quality: ruff (linting + formatting)"
echo "  - Type checking: ty"
# echo "  - Testing: pytest with coverage"
# echo "  - Build system: hatchling"
echo ""
echo "🔗 Git hooks are now active:"
# echo "  - Lefthook: Runs ruff, ty and pytest before commits"
echo "  - Lefthook: Runs ruff, ty before commits"
echo "  - Commit-msg: Validates commit message format with commitlint"
echo ""
echo "📋 Next steps:"
echo "  1. Copy .env.example to .env.development and customize settings"
# echo "  2. Run 'uv run pytest' to execute tests"
echo "  2. Run 'uv run ruff check --fix .' to fix any linting issues"
echo "  3. Start developing! 🐍✨"