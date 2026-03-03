# Install Node.js via NodeSource
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
fi
sudo apt-get install -y -qq nodejs
