#!/usr/bin/env bash

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Variables
readonly APP_NAME="gem"
readonly PYTHON_CMD="python3"
# Directory where the dedicated virtual environment for the app will be created
readonly VENV_DIR="$HOME/.local/share/gemini-cli-venv"
# Directory where the launcher script 'gem' will be installed
readonly INSTALL_DIR="$HOME/.local/bin"
# Find the project's root directory (assuming install.sh is in a 'scripts' subdir)
readonly PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REQUIREMENTS_FILE="$PROJECT_ROOT_DIR/requirements.txt"
readonly MAIN_MODULE="gemini_cli.cli"

# Colors (optional, but improves readability)
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_NC='\033[0m' # No Color

# Helper functions for messages
info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $1"
}

success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_NC} $1"
}

warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_NC} $1"
}

error_exit() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1" >&2
    exit 1
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        error_exit "$1 is not installed or not in PATH. Please install it and try again."
    fi
}

# 1. Check the operating system
info "Checking operating system..."
os="$(uname -s)"
if [[ "$os" != "Linux" && "$os" != "Darwin" ]]; then
    error_exit "This installation script is only supported on Linux and macOS (Unix-like systems)."
fi
success "Operating system is compatible."

# 2. Check system dependencies
info "Checking system dependencies..."
check_command "$PYTHON_CMD"
# venv is part of python3.3+
if ! "$PYTHON_CMD" -m venv -h &> /dev/null; then
    error_exit "Python 3 venv module is not available. Please ensure you have a full Python 3 installation."
fi
success "All system dependencies found."

# 3. Check for requirements file
info "Checking for requirements file..."
if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
    error_exit "Requirements file not found at $REQUIREMENTS_FILE"
fi
success "Requirements file found."

# 4. Create (or recreate) virtual environment
info "Setting up Python virtual environment in $VENV_DIR..."
if [ -d "$VENV_DIR" ]; then
    read -r -p "Virtual environment $VENV_DIR already exists. Recreate it? (y/n): " choice
    case "$choice" in
      y|Y )
        info "Removing existing virtual environment..."
        rm -rf "$VENV_DIR"
        ;;
      * )
        info "Using existing virtual environment. Dependencies will be updated."
        ;;
    esac
fi

if [ ! -d "$VENV_DIR" ]; then
    if ! "$PYTHON_CMD" -m venv "$VENV_DIR"; then
        error_exit "Failed to create virtual environment at $VENV_DIR."
    fi
fi
success "Virtual environment ready at $VENV_DIR."

# 5. Install dependencies using the venv's pip
venv_python="$VENV_DIR/bin/$PYTHON_CMD"
info "Upgrading pip in the virtual environment..."
if ! "$venv_python" -m pip install --upgrade pip; then
    warning "Failed to upgrade pip in the venv. Continuing with current version."
fi

info "Installing Python dependencies from $REQUIREMENTS_FILE into the virtual environment..."
if ! "$venv_python" -m pip install -r "$REQUIREMENTS_FILE"; then
    error_exit "Failed to install Python dependencies from $REQUIREMENTS_FILE into the venv."
fi
success "Python dependencies installed in virtual environment."

# 6. Create the installation directory for the command if it doesn't exist
info "Ensuring installation directory $INSTALL_DIR exists..."
if ! mkdir -p "$INSTALL_DIR"; then
    error_exit "Failed to create installation directory $INSTALL_DIR."
fi
success "Installation directory ready."

# 7. Crear el script lanzador en $INSTALL_DIR/$APP_NAME
info "Creating the command launcher at $INSTALL_DIR/$APP_NAME..."
cat << EOF > "$INSTALL_DIR/$APP_NAME"
#!/usr/bin/env bash
# Launcher for $APP_NAME

# The root directory of the project, determined during installation.
readonly APP_PROJECT_ROOT="${PROJECT_ROOT_DIR}"

# Activate the application's dedicated virtual environment
if [ -f "$VENV_DIR/bin/activate" ]; then
    # shellcheck source=/dev/null
    source "$VENV_DIR/bin/activate"
else
    echo -e "\033[0;31m[ERROR]\033[0m Virtual environment for $APP_NAME not found at $VENV_DIR/bin/activate." >&2
    echo -e "\033[0;31m[ERROR]\033[0m Please try reinstalling $APP_NAME." >&2
    exit 1
fi

# Temporarily add the project's root directory to PYTHONPATH
export PYTHONPATH="\${APP_PROJECT_ROOT}\${PYTHONPATH:+:\$PYTHONPATH}"

# Execute the Python script with all passed arguments
"$VENV_DIR/bin/$PYTHON_CMD" -m "$MAIN_MODULE" "\$@"
EOF

# 8. Make the launcher script executable
if ! chmod +x "$INSTALL_DIR/$APP_NAME"; then
    error_exit "Failed to make the launcher script $INSTALL_DIR/$APP_NAME executable."
fi
success "Command launcher $INSTALL_DIR/$APP_NAME created and made executable."

# 9. Check if $INSTALL_DIR is in the PATH and provide instructions
info "Checking if $INSTALL_DIR is in your PATH..."
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    warning "$INSTALL_DIR is not in your PATH."
    echo -e "To use the '${APP_NAME}' command directly, add $INSTALL_DIR to your PATH:"
    echo -e "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo -e "Then restart your terminal or source your shell config."
else
    success "$INSTALL_DIR is already in your PATH."
fi

# 10. Reminder about the API Key
echo ""
info "-----------------------------------------------------------------------"
info "Installation of '$APP_NAME' is complete!"
info ""
info "REMEMBER TO CONFIGURE YOUR API KEY:"
info "This application uses python-dotenv to load the GOOGLE_API_KEY."
info "Ensure you have a .env file where you run '${APP_NAME}',"
info "or set the GOOGLE_API_KEY env var globally."
info "Example .env content:"
info "  ${COLOR_YELLOW}GOOGLE_API_KEY=\"YOUR_GEMINI_API_KEY_HERE\"${COLOR_NC}"
info "-----------------------------------------------------------------------"
echo ""
success "Now you can run '$APP_NAME' from a new terminal session."
exit 0
