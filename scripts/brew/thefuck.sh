# Install thefuck — command correction (brew-only)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

if command -v thefuck &>/dev/null; then
  info "thefuck already installed"
else
  info "Installing thefuck via brew..."
  brew install thefuck
fi
