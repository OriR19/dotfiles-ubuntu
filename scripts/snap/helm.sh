# Install Helm via snap
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

if command -v helm &>/dev/null; then
  info "Helm already installed"
else
  info "Installing Helm via snap..."
  sudo snap install helm --classic
fi
