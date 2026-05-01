#!/usr/bin/env sh
id=$(notify-send "NixOS" "Building configuration..." --urgency=normal --expire-time=0 --print-id)
output=$(SUDO_PROMPT="NixOS" sudo -A nixos-rebuild switch --flake "$NIXOS_CONFIG#$NIXOS_HOST" 2>&1)
exit_code=$?

log_dir="$HOME/.local/share/nixos-builds"
mkdir -p "$log_dir"
log_file="$log_dir/$(date '+%Y-%m-%d_%H-%M-%S').log"

echo "$output" >"$log_file"
if [ $exit_code -eq 0 ]; then
  notify-send "NixOS" "Build successful" \
    --urgency=low \
    --replace-id=$id \
    --action="view=View Output"
else
  notify-send "NixOS" "Build failed" \
    --urgency=critical \
    --replace-id=$id \
    --action="view=View Output" \
    --expire-time=15000
fi | while read -r action; do
  if [ "$action" = "view" ]; then
    echo "$output" | fold -sw 130 | nl -ba -w2 -s"| " | rofi -dmenu -p "Build Output" -kb-accept-entry "" -kb-accept-custom "" -no-fixed-num-lines -theme "$HOME/.config/rofi/message-output.rasi"
  fi
done
