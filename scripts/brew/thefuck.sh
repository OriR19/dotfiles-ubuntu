# Install thefuck — command correction (brew-only)
if command -v thefuck &>/dev/null; then
  info "thefuck already installed"
else
  info "Installing thefuck via brew..."
  brew install thefuck
fi
