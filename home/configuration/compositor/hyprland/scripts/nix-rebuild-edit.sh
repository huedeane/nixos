#!/usr/bin/env sh
id=$(notify-send "NixOS (Edit Mode)" "Building configuration..." --urgency=normal --expire-time=0 --print-id)
log_dir="$HOME/.local/share/nixos-builds"
mkdir -p "$log_dir"

ts="$(date '+%Y-%m-%d_%H-%M-%S')"
active_file="$log_dir/${ts}.active.log"
log_file="$log_dir/${ts}.log"

script -qfec "SUDO_PROMPT='NixOS' EDIT_MODE=1 sudo -E -A nixos-rebuild switch --flake '$NIXOS_CONFIG#$NIXOS_HOST' --impure" /dev/null < /dev/null 2>&1 \
  | perl -ne '$| = 1; s/^\^\@// if $. == 1; s/\e\[[0-9;?]*[a-zA-Z]//g; s/\e\][^\a]*\a//g; s/[^\x09\x0a\x0d\x20-\x7e]//g; for my $l (split /[\r\n]+/) { print "$l\n" if $l =~ /\S/ }' \
  | tee "$active_file"
exit_code=${PIPESTATUS[0]}

mv "$active_file" "$log_file"

if [ $exit_code -eq 0 ]; then
  notify-send "NixOS (Edit Mode)" "Build successful" \
    --urgency=low \
    --replace-id=$id \
    --action="view=View Output"
else
  notify-send "NixOS (Edit Mode)" "Build failed" \
    --urgency=critical \
    --replace-id=$id \
    --action="view=View Output" \
    --expire-time=15000
fi | while read -r action; do
  if [ "$action" = "view" ]; then
    cat "$log_file" | fold -sw 130 | nl -ba -w2 -s"| " | rofi -dmenu -p "(Edit Mode) Build Output" -kb-accept-entry "" -kb-accept-custom "" -no-fixed-num-lines -theme "$HOME/.config/rofi/message-output.rasi"
  fi
done
