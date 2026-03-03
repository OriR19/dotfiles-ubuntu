# Install kubectl via snap
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

if command -v kubectl &>/dev/null; then
  info "kubectl already installed"
else
  info "Installing kubectl via snap..."
  sudo snap install kubectl --classic
fi
