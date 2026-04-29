#!/usr/bin/env sh

selected=$(ls "$HOME/.local/share/nixos-builds/" | rofi -dmenu -p "Build Logs")
if [ -n "$selected" ]; then
  cat "$HOME/.local/share/nixos-builds/$selected" | rofi -dmenu -p "$selected" -no-fixed-num-lines -theme "$HOME/.config/rofi/message-output-test.rasi"
fi
