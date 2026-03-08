# Install diffnav — git diff pager with file tree (brew-only)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

if command -v diffnav &>/dev/null; then
  info "diffnav already installed"
else
  info "Installing diffnav via brew..."
  brew install dlvhdr/formulae/diffnav
fi
