#!/usr/bin/env sh
session="nixos-build-edit"

tmux start-server
for s in nixos-build nixos-build-edit; do
  if tmux has-session -t "=$s" 2>/dev/null; then
    case "$s" in
      nixos-build-edit) running="Edit Mode" ;;
      *)                running="Normal" ;;
    esac
    notify-send "NixOS (Edit Mode)" "A build is already running ($running)" \
      --urgency=critical \
      --action="close=Close Session" \
    | while read -r action; do
        [ "$action" = "close" ] && tmux kill-session -t "=$s" 2>/dev/null
      done
    exit 1
  fi
done

log_dir="$HOME/.local/share/nixos-builds"
mkdir -p "$log_dir"
ts="$(date '+%Y-%m-%d_%H-%M-%S')"
active_file="$log_dir/${ts}.edit.active.log"
log_file="$log_dir/${ts}.edit.log"
status_file="$log_dir/${ts}.edit.status"
fifo="$log_dir/${ts}.edit.fifo"
id=$$

touch "$active_file"

old_limit=$(tmux show-options -gv history-limit 2>/dev/null || echo 2000)
tmux set-option -g history-limit 100000
tmux new-session -d -s "$session" -x 220 -y 50 \
  "SUDO_PROMPT='NixOS' EDIT_MODE=1 sudo -E -A nixos-rebuild switch --flake '$NIXOS_CONFIG#$NIXOS_HOST' --impure 2>&1; echo \$? > '$status_file'"
tmux set-option -g history-limit "$old_limit"
tmux set-option -w -t "$session" remain-on-exit on
tmux set-option -w -t "$session" automatic-rename off
tmux rename-window -t "$session" "nixos-rebuild-edit"

mkfifo "$fifo"
notify-send "NixOS (Edit Mode)" "Building configuration..." \
  --urgency=normal \
  --expire-time=0 \
  --replace-id="$id" \
  --action="view=View Output" > "$fifo" &
notify_pid=$!

while read -r action; do
  if [ "$action" = "view" ]; then
    kitty --class tui-tmux -e tmux attach -t "$session"
  fi
done < "$fifo" &
reader_pid=$!

while [ "$(tmux display-message -p -t "$session" '#{pane_dead}' 2>/dev/null)" != "1" ]; do
  sleep 1
done

kill "$notify_pid" 2>/dev/null
kill "$reader_pid" 2>/dev/null
rm -f "$fifo"

mv "$active_file" "$log_file"
tmux capture-pane -p -J -S - -t "$session" \
  | perl -ne 's/\e\[[0-9;?]*[a-zA-Z]//g; s/\e\][^\a]*\a//g; s/[^\x09\x0a\x0d\x20-\x7e]//g; for my $l (split /[\r\n]+/) { print "$l\n" if $l =~ /\S/ }' \
  > "$log_file"

exit_code=$(cat "$status_file" 2>/dev/null || echo 1)
rm -f "$status_file"

if [ "$exit_code" -eq 0 ]; then
  notify-send "NixOS (Edit Mode)" "Build successful" \
    --urgency=low \
    --replace-id="$id" \
    --action="view=View Output"
else
  notify-send "NixOS (Edit Mode)" "Build failed" \
    --urgency=critical \
    --replace-id="$id" \
    --action="view=View Output" \
    --expire-time=15000
fi | while read -r action; do
  if [ "$action" = "view" ]; then
    kitty --class tui-nvim -e nvim "$log_file"
  fi
done

tmux kill-session -t "$session" 2>/dev/null
