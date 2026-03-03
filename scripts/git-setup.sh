#!/usr/bin/env bash
# ─── Git + SSH key setup for GitHub ──────────────────────────────────────────
# Run interactively: sets git user, generates SSH key, registers it with GitHub.
# Can also be sourced from install.sh (will prompt for input).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

echo -e "\n${BLUE}══════ Git & SSH Setup ══════${NC}\n"

# ─── Git identity ───────────────────────────────────────────────────────────
current_name="$(git config --global user.name 2>/dev/null || true)"
current_email="$(git config --global user.email 2>/dev/null || true)"

if [ -n "$current_name" ] && [ -n "$current_email" ]; then
  info "Current git identity: $current_name <$current_email>"
  read -rp "Keep current git identity? [Y/n]: " keep
  if [[ "$keep" =~ ^[Nn]$ ]]; then
    current_name=""
    current_email=""
  fi
fi

if [ -z "$current_name" ]; then
  read -rp "Git name: " git_name
  git config --global user.name "$git_name"
  info "Set git user.name = $git_name"
fi

if [ -z "$current_email" ]; then
  read -rp "Git email: " git_email
  git config --global user.email "$git_email"
  info "Set git user.email = $git_email"
fi

# ─── Default branch ─────────────────────────────────────────────────────────
git config --global init.defaultBranch main
info "Set default branch to 'main'"

# ─── SSH key for GitHub ─────────────────────────────────────────────────────
SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
  info "SSH key already exists at $SSH_KEY"
else
  read -rp "Generate a new SSH key for GitHub? [Y/n]: " gen_key
  if [[ ! "$gen_key" =~ ^[Nn]$ ]]; then
    email="$(git config --global user.email)"
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""
    info "Generated SSH key at $SSH_KEY"
  fi
fi

# ─── Start ssh-agent and add key ────────────────────────────────────────────
if [ -f "$SSH_KEY" ]; then
  eval "$(ssh-agent -s)" >/dev/null 2>&1
  ssh-add "$SSH_KEY" 2>/dev/null
  info "SSH key added to agent"

  # ─── Add to GitHub ──────────────────────────────────────────────────────
  echo ""
  echo -e "${YELLOW}┌─────────────────────────────────────────────────────┐${NC}"
  echo -e "${YELLOW}│  Copy the public key below and add it to GitHub:   │${NC}"
  echo -e "${YELLOW}│  https://github.com/settings/ssh/new               │${NC}"
  echo -e "${YELLOW}└─────────────────────────────────────────────────────┘${NC}"
  echo ""
  cat "${SSH_KEY}.pub"
  echo ""

  # If gh CLI is available, offer to add automatically
  if command -v gh &>/dev/null; then
    read -rp "Add key to GitHub automatically via 'gh' CLI? [Y/n]: " auto_add
    if [[ ! "$auto_add" =~ ^[Nn]$ ]]; then
      gh ssh-key add "${SSH_KEY}.pub" --title "$(hostname)-$(date +%Y%m%d)"
      info "SSH key added to GitHub!"
    fi
  fi

  # ─── Configure git to use SSH instead of HTTPS for GitHub ──────────────
  git config --global url."git@github.com:".insteadOf "https://github.com/"
  info "Git configured to use SSH for GitHub clones"
fi

# ─── SSH config for GitHub ───────────────────────────────────────────────────
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
  mkdir -p "$HOME/.ssh"
  cat >> "$SSH_CONFIG" << 'SSHEOF'

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
SSHEOF
  chmod 600 "$SSH_CONFIG"
  info "Added GitHub entry to ~/.ssh/config"
fi

echo ""
info "Git + SSH setup complete!"
echo -e "  Test with: ${BLUE}ssh -T git@github.com${NC}"
