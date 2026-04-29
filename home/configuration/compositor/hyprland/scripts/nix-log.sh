#!/usr/bin/env sh

selected=$(ls -r "$HOME/.local/share/nixos-builds/" | rofi -dmenu -p "Build Logs")
if [ -n "$selected" ]; then
  cat "$HOME/.local/share/nixos-builds/$selected" | fold -sw 130 | nl -ba -w2 -s"| " | rofi -dmenu -p "$selected" -kb-accept-entry "" -kb-accept-custom "" -no-fixed-num-lines -theme "$HOME/.config/rofi/message-output.rasi"
fi
