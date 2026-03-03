# Install carapace — shell completion engine
# Uses the carapace-bin apt repo
if ! dpkg -l carapace-bin &>/dev/null; then
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://apt.carapace.sh/carapace.gpg | sudo tee /etc/apt/keyrings/carapace.gpg >/dev/null
  echo "deb [signed-by=/etc/apt/keyrings/carapace.gpg] https://apt.carapace.sh/ /" | sudo tee /etc/apt/sources.list.d/carapace.list >/dev/null
  sudo apt-get update -qq
fi
sudo apt-get install -y -qq carapace-bin
