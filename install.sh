#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
PACKAGES=(bash git inputrc profile starship carapace thefuck fonts vim)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# ─── 1. Install system packages ──────────────────────────────────────────────
install_apt_packages() {
  info "Installing system packages..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq stow fzf vim git curl build-essential
}

# ─── 2. Install Homebrew (linuxbrew) ─────────────────────────────────────────
install_brew() {
  if command -v brew &>/dev/null; then
    info "Homebrew already installed"
  else
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
  fi
}

# ─── 3. Install CLI tools via brew ───────────────────────────────────────────
install_brew_packages() {
  info "Installing CLI tools via brew..."
  brew install starship zoxide carapace thefuck 2>/dev/null || true
}

# ─── 4. Stow all packages ───────────────────────────────────────────────────
stow_packages() {
  info "Stowing dotfiles..."
  cd "$DOTFILES_DIR"

  # Ensure .config exists (stow needs the parent for nested links)
  mkdir -p "$HOME/.config"

  for pkg in "${PACKAGES[@]}"; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
      # --adopt: if a file already exists, adopt it into the repo then overwrite
      # --restow: re-create symlinks cleanly
      stow --restow --target="$HOME" "$pkg" 2>/dev/null && info "  Stowed $pkg" || warn "  $pkg had conflicts, trying with --adopt..."
      stow --adopt --restow --target="$HOME" "$pkg" 2>/dev/null && info "  Adopted & stowed $pkg" || error "  Failed to stow $pkg"
    fi
  done
}

# ─── 5. Post-install ────────────────────────────────────────────────────────
post_install() {
  # Rebuild font cache if fontconfig is available
  if command -v fc-cache &>/dev/null && [ -d "$HOME/.fonts" ]; then
    info "Rebuilding font cache..."
    fc-cache -fv "$HOME/.fonts" >/dev/null 2>&1
  fi

  info "Done! Restart your shell or run: source ~/.bashrc"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║       Dotfiles Bootstrap Script      ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  if [ ! -d "$DOTFILES_DIR" ]; then
    error "$DOTFILES_DIR not found. Clone the repo first:"
    echo "  git clone <repo-url> ~/.dotfiles"
    exit 1
  fi

  install_apt_packages
  install_brew
  install_brew_packages
  stow_packages
  post_install
}

main "$@"
