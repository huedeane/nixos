#!/usr/bin/env sh
log_dir="$HOME/.local/share/nixos-builds"

selected=$(ls -r "$log_dir/" | grep -v -e '\.fifo$' -e '\.status$' | rofi -dmenu -p "Build Logs")
[ -n "$selected" ] || exit 0

case "$selected" in
  *.active.log)
    case "$selected" in
      *.edit.active.log) session="nixos-build-edit" ;;
      *)                 session="nixos-build" ;;
    esac
    if tmux has-session -t "$session" 2>/dev/null; then
      kitty --class tui-tmux -e tmux attach -t "$session"
    else
      notify-send "NixOS" "Build finished — session '$session' is gone" --urgency=normal
    fi
    ;;
  *)
    fold -sw 130 < "$log_dir/$selected" \
      | nl -ba -w2 -s"| " \
      | rofi -dmenu -p "$selected" -kb-accept-entry "" -kb-custom-1 "Return" -no-fixed-num-lines -theme "$HOME/.config/rofi/message-output.rasi"
    if [ $? -eq 10 ]; then
      kitty --class tui-nvim -e nvim "$log_dir/$selected"
    fi
    ;;
esac
