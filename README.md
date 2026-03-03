# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Modular install scripts — just drop a `.sh` file in the right folder.

## One-liner setup on a new machine

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OriR19/dotfiles/main/install.sh)
```

> This clones the repo, installs all tools, and symlinks all configs. Works on any fresh Ubuntu/Debian machine.

## Structure

```
~/.dotfiles/
├── install.sh              # Self-bootstrapping entry point (curl-able)
├── scripts/
│   ├── apt/                # *.sh → auto-installed via apt
│   │   ├── base-deps.sh
│   │   ├── carapace.sh
│   │   ├── fzf.sh
│   │   ├── stow.sh
│   │   ├── vim.sh
│   │   └── zoxide.sh
│   ├── brew/               # *.sh → installed via Homebrew (for brew-only packages)
│   │   └── thefuck.sh
│   └── custom/             # *.sh → custom install logic (curl installers etc.)
│       ├── homebrew.sh
│       └── starship.sh
├── bash/                   # stow: .bashrc, .bash_logout, .bash_carapace
├── git/                    # stow: .gitconfig
├── inputrc/                # stow: .inputrc
├── profile/                # stow: .profile
├── starship/               # stow: .config/starship.toml
├── carapace/               # stow: .config/carapace/
├── thefuck/                # stow: .config/thefuck/
├── fonts/                  # stow: .fonts/
└── vim/                    # stow: .viminfo
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
