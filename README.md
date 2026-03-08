# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Modular install scripts — just drop a `.sh` file in the right folder.

## Quick Setup

### One-liner (curl)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OriR19/dotfiles-ubuntu/main/install.sh)
```

### Manual clone

```bash
git clone https://github.com/OriR19/dotfiles-ubuntu.git ~/.dotfiles
cd ~/.dotfiles && ./install.sh
```

## What the installer does

The `install.sh` script is fully self-bootstrapping — it can run on a bare Ubuntu/Debian machine:

1. **Clone** — If `~/.dotfiles` doesn't exist, it clones the repo from GitHub
2. **APT packages** — Runs every `scripts/apt/*.sh` (stow, fzf, vim, terraform, docker, gcloud, etc.)
3. **Snap packages** — Runs every `scripts/snap/*.sh` (kubectl, helm)
4. **Custom installers** — Runs every `scripts/custom/*.sh` (Homebrew, Starship via curl)
5. **Brew packages** — Runs every `scripts/brew/*.sh` (thefuck — brew-only)
6. **Stow configs** — Symlinks all dotfile packages (bash, vim, starship, etc.) to `$HOME`
7. **Post-install** — Rebuilds font cache
8. **Git + SSH setup** *(interactive, opt-in)* — Prompts for git name/email, generates an SSH key, and optionally registers it with GitHub via `gh ssh-key add`

Every install script is independent — you can run any one of them individually without breaking the others.

## Structure

```
~/.dotfiles/
├── install.sh              # Self-bootstrapping entry point (curl-able)
├── scripts/
│   ├── helpers.sh          # Shared colored output helpers
│   ├── git-setup.sh        # Interactive: git identity + SSH key for GitHub
│   ├── apt/                # *.sh → auto-installed via apt
│   │   ├── base-deps.sh
│   │   ├── carapace.sh
│   │   ├── docker.sh
│   │   ├── fzf.sh
│   │   ├── gcloud.sh
│   │   ├── gh-cli.sh
│   │   ├── jq.sh
│   │   ├── nodejs.sh
│   │   ├── stow.sh
│   │   ├── terraform.sh
│   │   ├── tree-tmux.sh
│   │   ├── vim.sh
│   │   └── zoxide.sh
│   ├── snap/               # *.sh → installed via snap
│   │   ├── helm.sh
│   │   └── kubectl.sh
│   ├── brew/               # *.sh → Homebrew (for brew-only packages)
│   │   ├── diffnav.sh
│   │   ├── gum.sh
│   │   └── thefuck.sh
│   └── custom/             # *.sh → custom install logic (curl installers etc.)
│       ├── gh-dash.sh
│       ├── gh-enhance.sh
│       ├── homebrew.sh
│       └── starship.sh
├── bash/                   # stow: .bashrc, .bash_logout, .bash_carapace
├── inputrc/                # stow: .inputrc
├── profile/                # stow: .profile
├── starship/               # stow: .config/starship.toml
├── carapace/               # stow: .config/carapace/
├── thefuck/                # stow: .config/thefuck/
├── gh-dash/                # stow: .config/gh-dash/config.yml
├── fonts/                  # stow: .fonts/ (JetBrains Mono Nerd Font)
└── vim/                    # stow: .vimrc, .viminfo
```

## Adding a new tool

Just drop a shell script in the right folder:

```bash
# Example: add bat via apt
echo 'sudo apt-get install -y -qq bat' > scripts/apt/bat.sh
git add scripts/apt/bat.sh && git commit -m "Add bat"
```

No changes to `install.sh` needed — it auto-discovers all `*.sh` files.

## Manual stow commands

```bash
cd ~/.dotfiles
stow bash              # stow a single package
stow -D bash           # unstow a package
stow -R bash           # re-stow (after restructuring)
```
