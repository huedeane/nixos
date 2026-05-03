#!/usr/bin/env sh

check_paths() {
  for path in "$@"; do
    if [ ! -e "$path" ]; then
      echo "Error: path not found: $path"
      return 1
    fi
  done
}

nix-rebuild() {
  local host="${1:-$NIXOS_HOST}"
  check_paths \
    "$NIXOS_CONFIG/hosts/profiles/$host/configuration.nix" \
    || return 1
  sudo nixos-rebuild switch --flake "$NIXOS_CONFIG#$host"
}

nix-edit() {
  check_paths \
    "$NIXOS_CONFIG/hosts/profiles/$NIXOS_HOST/configuration.nix" \
    || return 1

  nvim "$NIXOS_CONFIG/hosts/profiles/$NIXOS_HOST/configuration.nix"
}

hm-edit() {
  check_paths \
    "$NIXOS_CONFIG/home/profiles/$1.nix" \
    || return 1

  nvim "$NIXOS_CONFIG/home/profiles/$1.nix"
}

help() {
  echo ""
  echo "Nix"
  echo "  nix-rebuild <host> --> rebuild nixos config"
	echo "  nix-edit <host> --> edit host configuration.nix"
  echo "  hm-edit <host> --> edit home.nix"
  echo ""
  echo "Aliases"
  echo "  f --> yazi file manager"
  echo "  m --> rmpc music player"
  echo "  bash-update --> reload bashrc"
  echo "  secret-update --> edit secrets.json"
  echo "  hypr-update --> edit hyprland.conf"
  echo ""
}
