#!/usr/bin/env bash

# Print the theme that fits a COLS x ROWS window (defaults to the current terminal)
if [ -z "$COLS" ] || [ -z "$ROWS" ]; then
  read -r ROWS COLS < <(stty size < /dev/tty)
fi

if [ "$COLS" -gt 170 ]; then
  theme=catppuccin_frappe
elif [ "$COLS" -gt 100 ]; then
  theme=catppuccin_frappe_mobile
else
  theme=catppuccin_frappe_small
fi

# Short windows drop the cover + cava row so the queue keeps its space
if [ "$theme" != catppuccin_frappe ] && [ "$ROWS" -lt 36 ]; then
  theme="${theme}_compact"
fi

echo "$HOME/.config/rmpc/themes/$theme.ron"
