# Install gh-dash — rich terminal UI for GitHub (gh extension)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

if gh extension list 2>/dev/null | grep -q "dlvhdr/gh-dash"; then
  info "gh-dash already installed"
else
  if ! command -v gh &>/dev/null; then
    warn "gh CLI not found — skipping gh-dash"
  else
    info "Installing gh-dash..."
    gh extension install dlvhdr/gh-dash
  fi
fi
