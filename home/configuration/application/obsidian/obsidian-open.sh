#!/usr/bin/env bash

# Open a markdown file in Obsidian, which can only open files inside a vault: files in a
# registered vault open there, anything else is symlinked into a scratch vault and opened
# from it (edits go straight to the real file)
scratch="${XDG_DATA_HOME:-$HOME/.local/share}/obsidian-scratch"
config="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian/obsidian.json"
profile="${XDG_DATA_HOME:-$HOME/.local/share}/obsidianplugins/Profiles/Tui"

if [ -z "$1" ]; then
  setsid -f obsidian >/dev/null 2>&1
  exit
fi
file=$(realpath "$1")

# Deepest registered vault that contains the file (vaults can be nested)
vault=$(jq -r --arg f "$file" --arg s "$scratch" \
  '.vaults[].path | select(. != $s and ($f | startswith(. + "/")))' "$config" 2>/dev/null |
  awk '{ print length, $0 }' | sort -rn | head -1 | cut -d' ' -f2-)

if [ -n "$vault" ]; then
  target="$file"
else
  # First use: give the scratch vault the Tui profile's settings, minus homepage, which would
  # replace the opened file with a Home note the scratch vault doesn't have
  if [ ! -d "$scratch/.obsidian" ]; then
    mkdir -p "$scratch/.obsidian"
    if [ -d "$profile" ]; then
      cp -RL "$profile"/. "$scratch/.obsidian"/
      rm -rf "$scratch/.obsidian/plugins/homepage" "$scratch/.obsidian/profile.json"
      plugins="$scratch/.obsidian/community-plugins.json"
      jq 'map(select(. != "homepage"))' "$plugins" > "$plugins.tmp" && mv "$plugins.tmp" "$plugins"
    fi
  fi
  # Register it as a vault so obsidian://open?path= can find files in it
  if ! jq -e --arg s "$scratch" 'any(.vaults[]?; .path == $s)' "$config" >/dev/null 2>&1; then
    mkdir -p "$(dirname "$config")"
    [ -s "$config" ] || echo '{}' > "$config"
    jq --arg id "$(printf '%s' "$scratch" | md5sum | cut -c1-16)" --arg s "$scratch" \
      --argjson ts "$(date +%s)000" '.vaults[$id] = { path: $s, ts: $ts }' "$config" > "$config.tmp" &&
      mv "$config.tmp" "$config"
  fi
  # Drop links to files that no longer exist
  find "$scratch" -maxdepth 1 -xtype l -delete
  # Reuse the link if this file was opened before; otherwise avoid clashing names
  name=$(basename "$file")
  target="$scratch/$name"
  n=1
  while [ -e "$target" ] && [ "$(realpath "$target")" != "$file" ]; do
    target="$scratch/${name%.*} ($n).${name##*.}"
    n=$((n + 1))
  done
  ln -sfn "$file" "$target"
fi

setsid -f obsidian "obsidian://open?path=$(jq -rn --arg p "$target" '$p | @uri')" >/dev/null 2>&1
