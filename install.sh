#!/usr/bin/env bash
set -e

# ─── Config ─────────────────────────────────────────────────────────────────
DOTFILES_REPO="https://github.com/OriR19/dotfiles.git"  # ← UPDATE THIS
DOTFILES_DIR="$HOME/.dotfiles"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# ─── Colors / helpers ────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; }
section() { echo -e "\n${BLUE}══════ $1 ══════${NC}"; }

# Run every *.sh found in a directory (sorted, so you can prefix with numbers)
run_scripts_in() {
  local dir="$1"
  local label="$2"
  if [ -d "$dir" ] && compgen -G "$dir/*.sh" >/dev/null; then
    for script in "$dir"/*.sh; do
      local name
      name="$(basename "$script" .sh)"
      info "  [$label] $name"
      # shellcheck disable=SC1090
      source "$script"
    done
  else
    warn "  No scripts found in $dir"
  fi
}

# ─── 1. Clone repo if missing ───────────────────────────────────────────────
clone_dotfiles() {
  if [ -d "$DOTFILES_DIR/.git" ]; then
    info "Dotfiles repo already present at $DOTFILES_DIR"
    cd "$DOTFILES_DIR" && git pull --ff-only 2>/dev/null || true
  else
    info "Cloning dotfiles repo..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
}

# ─── 2. APT packages ────────────────────────────────────────────────────────
install_apt() {
  section "APT packages"
  sudo apt-get update -qq
  run_scripts_in "$SCRIPTS_DIR/apt" "apt"
}

# ─── 3. Custom installers (curl scripts, etc.) ──────────────────────────────
install_custom() {
  section "Custom installers"
  run_scripts_in "$SCRIPTS_DIR/custom" "custom"
}

# ─── 4. Brew packages (only for things not in apt/snap) ─────────────────────
install_brew() {
  section "Brew packages"
  # Ensure brew is available (homebrew.sh in custom/ installs it)
  if command -v brew &>/dev/null; then
    eval "$(brew shellenv bash 2>/dev/null)" || true
    run_scripts_in "$SCRIPTS_DIR/brew" "brew"
  else
    warn "Homebrew not found — skipping brew packages"
    warn "Add homebrew.sh to scripts/custom/ to enable"
  fi
}

# ─── 5. Stow all packages ───────────────────────────────────────────────────
stow_packages() {
  section "Stowing dotfiles"
  cd "$DOTFILES_DIR"
  mkdir -p "$HOME/.config"

  # Auto-discover stow packages: any top-level dir that isn't scripts/.git/etc.
  for pkg_dir in "$DOTFILES_DIR"/*/; do
    local pkg
    pkg="$(basename "$pkg_dir")"
    # Skip non-stow directories
    [[ "$pkg" =~ ^(scripts|\.git)$ ]] && continue
    stow --restow --target="$HOME" "$pkg" 2>/dev/null \
      && info "  Stowed $pkg" \
      || { stow --adopt --restow --target="$HOME" "$pkg" 2>/dev/null \
           && info "  Adopted & stowed $pkg" \
           || error "  Failed to stow $pkg"; }
  done
}

# ─── 6. Post-install ────────────────────────────────────────────────────────
post_install() {
  section "Post-install"
  if command -v fc-cache &>/dev/null && [ -d "$HOME/.fonts" ]; then
    info "Rebuilding font cache..."
    fc-cache -f "$HOME/.fonts" >/dev/null 2>&1
  fi
  info "Done! Restart your shell or run:  source ~/.bashrc"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║       Dotfiles Bootstrap Script      ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  # If run via curl (no repo present), clone first
  clone_dotfiles

  install_apt
  install_custom
  install_brew
  stow_packages
  post_install
}

main "$@"
