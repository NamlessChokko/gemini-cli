#!/usr/bin/env bash

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Cleanup on exit (deactivate venv if active)
cleanup() {
    deactivate &>/dev/null || true
}
trap cleanup EXIT

# Parse flags
FORCE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)
            FORCE=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Color setup (only if output is a TTY)
if [[ -t 1 ]]; then
    readonly COLOR_RED='\033[0;31m'
    readonly COLOR_GREEN='\033[0;32m'
    readonly COLOR_YELLOW='\033[0;33m'
    readonly COLOR_BLUE='\033[0;34m'
    readonly COLOR_NC='\033[0m'
else
    readonly COLOR_RED=''
    readonly COLOR_GREEN=''
    readonly COLOR_YELLOW=''
    readonly COLOR_BLUE=''
    readonly COLOR_NC=''
fi

# Helper functions
info() { echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $1"; }
success() { echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_NC} $1"; }
warning() { echo -e "${COLOR_YELLOW}[WARNING]${COLOR_NC} $1"; }
error_exit() { echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1" >&2; exit 1; }
check_command() { command -v "$1" &>/dev/null || error_exit "$1 is not installed or not in PATH."; }

# Variables
readonly APP_NAME="gem"
readonly PYTHON_CMD="python3"
readonly VENV_DIR="$HOME/.local/share/gemini-cli-venv"
readonly INSTALL_DIR="$HOME/.local/bin"
readonly PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REQUIREMENTS_FILE="$PROJECT_ROOT_DIR/requirements.txt"
readonly MAIN_MODULE="gemini_cli.cli"

# 1. Check operating system
info "Checking operating system..."
os="$(uname -s)"
if [[ "$os" != "Linux" && "$os" != "Darwin" ]]; then
    error_exit "This script runs only on Linux or macOS."
fi
success "Operating system: $os"

# 2. Check Python version (>=3.8)
info "Checking Python version..."
check_command "$PYTHON_CMD"
ver="$($PYTHON_CMD -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
if [[ "$(printf '%s\n' "$ver" '3.8' | sort -V | head -n1)" != "3.8" ]]; then
    error_exit "Requires Python >= 3.8 (found $ver)."
fi
success "Python version $ver"

# 3. Check for requirements file
info "Locating requirements file..."
if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
    error_exit "Requirements file not found at $REQUIREMENTS_FILE"
fi
success "Requirements file found"

# 4. Create or reuse virtual environment
info "Setting up virtual environment at $VENV_DIR..."
if [[ -d "$VENV_DIR" ]]; then
    if $FORCE; then
        info "--force: removing existing venv..."
        rm -rf "$VENV_DIR"
    else
        info "Reusing existing venv (use --force to recreate)."
    fi
fi
if [[ ! -d "$VENV_DIR" ]]; then
    "$PYTHON_CMD" -m venv "$VENV_DIR" || error_exit "Failed to create venv."
fi
success "Virtual environment ready"

# 5. Install dependencies inside venv
venv_python="$VENV_DIR/bin/$PYTHON_CMD"
info "Upgrading pip in venv..."
$venv_python -m pip install --upgrade pip || warning "Could not upgrade pip"

info "Installing dependencies from requirements.txt..."
$venv_python -m pip install -r "$REQUIREMENTS_FILE" || error_exit "Dependency installation failed"
success "Dependencies installed"

# 5a. Verify key package
if ! $venv_python -m pip show google-generativeai &>/dev/null; then
    warning "google-generativeai not found in venv. Double-check requirements.txt"
else
    success "Key package google-generativeai is installed"
fi

# 6. Prepare launcher directory
info "Ensuring install directory $INSTALL_DIR exists..."
mkdir -p "$INSTALL_DIR" || error_exit "Cannot create $INSTALL_DIR"
success "Install directory ready"

# 7. Create launcher script
info "Writing launcher to $INSTALL_DIR/$APP_NAME..."
cat << EOF > "$INSTALL_DIR/$APP_NAME"
#!/usr/bin/env bash
# Launcher for $APP_NAME
readonly APP_PROJECT_ROOT="$PROJECT_ROOT_DIR"
# Activate venv
if [[ -f "$VENV_DIR/bin/activate" ]]; then
    source "$VENV_DIR/bin/activate"
else
    echo -e "\${COLOR_RED}[ERROR]\${COLOR_NC} venv not found at $VENV_DIR/bin/activate" >&2
    exit 1
fi
# Add project to PYTHONPATH
export PYTHONPATH="\$APP_PROJECT_ROOT\${PYTHONPATH:+:\$PYTHONPATH}"
# Execute
"$VENV_DIR/bin/$PYTHON_CMD" -m "$MAIN_MODULE" "\$@"
EOF
chmod +x "$INSTALL_DIR/$APP_NAME" || error_exit "Cannot chmod launcher"
success "Launcher created"

# 8. PATH reminder
info "Checking if $INSTALL_DIR is in PATH..."
if [[ ":\$PATH:" != *":$INSTALL_DIR:"* ]]; then
    warning "$INSTALL_DIR not in PATH. Add it to use '$APP_NAME' directly"
    echo "  export PATH=\"\\$HOME/.local/bin:\\$PATH\""
fi

# 9. Final message
info "--------------------------------------------------"
success "Installation complete. Run 'gem --help' to get started."
exit 0
