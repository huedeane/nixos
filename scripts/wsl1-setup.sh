#!/usr/bin/env sh

# Create nix config
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf << 'EOF'
filter-syscalls = false
experimental-features = nix-command flakes
EOF

# Install dependencies
sudo apt update
sudo apt install -y curl xz-utils git

# Download and install Nix
sudo install -d -m755 -o $(id -u) -g $(id -g) /nix
curl -L https://nixos.org/nix/install -o /tmp/install.sh
sh /tmp/install.sh --no-daemon --no-channel-add
nix run home-manager/master -- switch --flake .#standalone -b backup
