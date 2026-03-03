#!/usr/bin/env bash
set -e

# ─── Config ─────────────────────────────────────────────────────────────────
DOTFILES_REPO="https://github.com/OriR19/dotfiles-ubuntu.git"
DOTFILES_DIR="$HOME/.dotfiles"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# ─── Colors / helpers ────────────────────────────────────────────────────────
# shellcheck disable=SC1091
source "$SCRIPTS_DIR/helpers.sh" 2>/dev/null || {
  # Fallback if helpers.sh not yet available (curl bootstrap before clone)
  info()    { echo "[✓] $1"; }
  warn()    { echo "[!] $1"; }
  error()   { echo "[✗] $1"; }
  section() { echo "══════ $1 ══════"; }
}

# Run every *.sh found in a directory (sorted, so you can prefix with numbers)
# Skips scripts that require interactive input (prefixed with "interactive-")
run_scripts_in() {
  local dir="$1"
  local label="$2"
  if [ -d "$dir" ] && compgen -G "$dir/*.sh" >/dev/null; then
    for script in "$dir"/*.sh; do
      local name
      name="$(basename "$script" .sh)"
      # Skip the helpers file and interactive scripts
      [[ "$name" == "helpers" ]] && continue
      info "  [$label] $name"
      # shellcheck disable=SC1090
      source "$script"
    done
  else
    warn "  No scripts found in $dir"
  fi
}

# ─── 1. Ensure git and curl are available ────────────────────────────────────
ensure_prerequisites() {
  for cmd in git curl sudo; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Installing $cmd..."
      apt-get update -qq 2>/dev/null || true
      apt-get install -y -qq git curl sudo
      break
    fi
  done
}

# ─── 2. Clone repo if missing ───────────────────────────────────────────────
clone_dotfiles() {
  if [ -d "$DOTFILES_DIR/.git" ]; then
    info "Dotfiles repo already present at $DOTFILES_DIR"
    cd "$DOTFILES_DIR" && git pull --ff-only 2>/dev/null || true
  else
    info "Cloning dotfiles repo..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
  # Re-source helpers now that repo is available
  # shellcheck disable=SC1091
  source "$SCRIPTS_DIR/helpers.sh" 2>/dev/null || true
}

# ─── 2. APT packages ────────────────────────────────────────────────────────
install_apt() {
  section "APT packages"
  sudo apt-get update -qq
  run_scripts_in "$SCRIPTS_DIR/apt" "apt"
}

# ─── 3. Snap packages ───────────────────────────────────────────────────────
install_snap() {
  section "Snap packages"
  if command -v snap &>/dev/null; then
    run_scripts_in "$SCRIPTS_DIR/snap" "snap"
  else
    warn "Snap not available — skipping snap packages"
  fi
}

# ─── 4. Custom installers (curl scripts, etc.) ──────────────────────────────
install_custom() {
  section "Custom installers"
  run_scripts_in "$SCRIPTS_DIR/custom" "custom"
}

# ─── 5. Brew packages (only for things not in apt/snap) ─────────────────────
install_brew() {
  section "Brew packages"
  if command -v brew &>/dev/null; then
    eval "$(brew shellenv bash 2>/dev/null)" || true
    run_scripts_in "$SCRIPTS_DIR/brew" "brew"
  else
    warn "Homebrew not found — skipping brew packages"
    warn "Add homebrew.sh to scripts/custom/ to enable"
  fi
}

# ─── 6. Stow all packages ───────────────────────────────────────────────────
stow_packages() {
  section "Stowing dotfiles"
  cd "$DOTFILES_DIR"
  mkdir -p "$HOME/.config" "$HOME/.vim/undodir"

  for pkg_dir in "$DOTFILES_DIR"/*/; do
    local pkg
    pkg="$(basename "$pkg_dir")"
    [[ "$pkg" =~ ^(scripts|\.git)$ ]] && continue
    stow --restow --target="$HOME" "$pkg" 2>/dev/null \
      && info "  Stowed $pkg" \
      || { stow --adopt --restow --target="$HOME" "$pkg" 2>/dev/null \
           && info "  Adopted & stowed $pkg" \
           || error "  Failed to stow $pkg"; }
  done
}

# ─── 7. Post-install ────────────────────────────────────────────────────────
post_install() {
  section "Post-install"
  if command -v fc-cache &>/dev/null && [ -d "$HOME/.fonts" ]; then
    info "Rebuilding font cache..."
    fc-cache -f "$HOME/.fonts" >/dev/null 2>&1
  fi
  info "Done! Restart your shell or run:  source ~/.bashrc"
}

# ─── 8. Interactive setup (git identity + SSH keys) ─────────────────────────
interactive_setup() {
  section "Interactive setup"
  local git_setup="$SCRIPTS_DIR/git-setup.sh"
  if [ -f "$git_setup" ]; then
    read -rp "Run git + SSH key setup? [Y/n]: " run_git
    if [[ ! "$run_git" =~ ^[Nn]$ ]]; then
      bash "$git_setup"
    fi
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║       Dotfiles Bootstrap Script      ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  ensure_prerequisites
  clone_dotfiles
  install_apt
  install_snap
  install_custom
  install_brew
  stow_packages
  post_install
  interactive_setup
}

main "$@"
