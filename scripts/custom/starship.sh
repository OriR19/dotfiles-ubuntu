# Install starship — cross-shell prompt
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

if command -v starship &>/dev/null; then
  info "Starship already installed"
else
  info "Installing Starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi
