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

nix-rebuild-edit() {
  local host="${1:-$NIXOS_HOST}"
  check_paths \
    "$NIXOS_CONFIG/hosts/profiles/$host/configuration.nix" \
    || return 1
  EDIT_MODE=1 sudo -E nixos-rebuild switch --flake "$NIXOS_CONFIG#$host" --impure
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

# Mount every unmounted filesystem (external / secondary drives).
# Dynamic: skips anything already mounted (system disk, boot) and swap.
mount-all() {
  local link dev
  for link in /dev/disk/by-uuid/*; do
    [ -e "$link" ] || continue
    dev=$(readlink -f "$link")
    findmnt -S "$dev" >/dev/null 2>&1 && continue
    swapon --show=NAME --noheadings 2>/dev/null | grep -qx "$dev" && continue
    echo "Mounting $dev ..."
    udisksctl mount -b "$dev"
  done
}

# Unmount everything mounted under /run/media/$USER.
unmount-all() {
  local m
  for m in "/run/media/$USER"/*; do
    [ -d "$m" ] || continue
    findmnt "$m" >/dev/null 2>&1 || continue
    echo "Unmounting $m ..."
    udisksctl unmount -b "$(findmnt -no SOURCE "$m")"
  done
}

# Mount / unmount a connected phone over MTP (generic — any device).
phone() {
  local uid uri mp
  uid=$(id -u)
  uri=$(gio mount -li 2>/dev/null | grep -oE 'activation_root=mtp://[^[:space:]]+' | sed 's/^activation_root=//' | head -1)

  if [ "$1" = "-u" ] || [ "$1" = "unmount" ]; then
    if [ -n "$uri" ]; then gio mount -u "$uri" && echo "Phone unmounted."; else echo "No phone mounted."; fi
    return
  fi

  if [ -z "$uri" ]; then
    echo "No phone detected. Plug it in and choose 'File transfer' on the device."
    return 1
  fi

  gio mount "$uri" >/dev/null 2>&1
  mp=$(find "/run/user/$uid/gvfs" -maxdepth 1 -name 'mtp:host=*' 2>/dev/null | head -1)
  if [ -z "$mp" ]; then
    echo "Mounted, but couldn't find it under /run/user/$uid/gvfs."
    return 1
  fi
  echo "Phone mounted at: $mp"
  cd "$mp" 2>/dev/null && ls
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
  echo "Mount"
  echo "  mount-all --> mount all external / secondary drives"
  echo "  unmount-all --> unmount all external drives"
  echo "  phone / phone -u --> mount / unmount a connected phone (MTP)"
  echo ""
}
