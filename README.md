# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Each top-level directory is a stow "package" that mirrors the home directory layout:

```
~/.dotfiles/
├── bash/           # .bashrc, .bash_logout, .bash_carapace
├── git/            # .gitconfig
├── inputrc/        # .inputrc
├── profile/        # .profile
├── starship/       # .config/starship.toml
├── carapace/       # .config/carapace/
├── thefuck/        # .config/thefuck/
├── fonts/          # .fonts/
└── vim/            # .viminfo
```

## Usage

### Install all packages
```bash
cd ~/.dotfiles
stow bash git inputrc profile starship carapace thefuck fonts vim
```

### Install a single package
```bash
cd ~/.dotfiles
stow bash
```

### Uninstall a package
```bash
cd ~/.dotfiles
stow -D bash
```

### Re-stow (useful after adding new files to a package)
```bash
cd ~/.dotfiles
stow -R bash
```

## Setup on a new machine

```bash
sudo apt install stow
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
stow bash git inputrc profile starship carapace thefuck fonts vim
```
