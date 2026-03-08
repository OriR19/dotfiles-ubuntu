# Install gh-enhance — terminal UI for GitHub Actions (gh extension)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

if gh extension list 2>/dev/null | grep -q "dlvhdr/gh-enhance"; then
  info "gh-enhance already installed"
else
  if ! command -v gh &>/dev/null; then
    warn "gh CLI not found — skipping gh-enhance"
  else
    info "Installing gh-enhance..."
    gh extension install dlvhdr/gh-enhance
  fi
fi
