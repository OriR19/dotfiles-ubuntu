# Install starship — cross-shell prompt
if command -v starship &>/dev/null; then
  info "Starship already installed"
else
  info "Installing Starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi
