#!/usr/bin/env bash
FILE="${HM_FILE:-$HOME/.config/nixos/home/profiles/packages.toml}"

pkg=$(echo "$1" | awk '{ print $NF }' | sed 's:.*/::')

# quote only when the name isn't a valid TOML bare key
case "$pkg" in
  *[!A-Za-z0-9_-]*) key="\"$pkg\"" ;;
  *)                key="$pkg" ;;
esac

mkdir -p "$(dirname "$FILE")"
grep -q '^\[packages\]' "$FILE" 2>/dev/null || echo '[packages]' >> "$FILE"

# exact key match, quoted or not
if awk -F= -v p="$pkg" '{ gsub(/[ \t"]/, "", $1); if ($1 == p) found=1 }
                        END { exit !found }' "$FILE"; then
  notify-send "Nix Package Manager" "\"$pkg\" pkgs already added"
elif echo "$key = true" >> "$FILE"; then
  notify-send "Nix Package Manager" "\"$pkg\" pkgs added"
else
  notify-send "Nix Package Manager" "Failed to add pkgs \"$pkg\"" --urgency=critical
fi
