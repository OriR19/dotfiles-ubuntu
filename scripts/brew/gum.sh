# Install gum — a tool for glamorous shell scripts (used by gh-dash approve keybind)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

if command -v gum &>/dev/null; then
  info "gum already installed"
else
  info "Installing gum via brew..."
  brew install gum
fi
