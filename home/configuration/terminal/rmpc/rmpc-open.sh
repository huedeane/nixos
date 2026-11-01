#!/usr/bin/env sh

music="$HOME/Music"
self="$0"

if [ "$1" = "--close" ]; then
  rmpc --partition single stop >/dev/null 2>&1
  rmpc --partition single clear >/dev/null 2>&1
  mpd-partition switch default
  tmux kill-session -t MusicSingle 2>/dev/null
  exit 0
fi

if [ "$#" -gt 0 ]; then
  mpd-partition switch single
  rmpc --partition single clear

  for file in "$@"; do
    file=$(realpath "$file")
    case "$file" in
    "$music"/*) rmpc --partition single add "${file#"$music"/}" || rmpc --partition single add "$file" ;;
    *) rmpc --partition single add "$file" ;;
    esac
  done

  rmpc --partition single play 0
  class="tui-rmpc-single"
  command="unset TMUX; trap '$self --close' HUP; tmux new-session -A -s MusicSingle 'rmpc --partition single; $self --close'; $self --close"
else
  class="tui-rmpc"
  command="rmpc"
fi

if hyprctl clients -j | jq -e --arg class "$class" '.[] | select(.class == $class)' >/dev/null; then
  hyprctl dispatch "hl.dsp.focus({ window = \"class:^$class\$\" })"
else
  setsid -f kitty --class "$class" -o confirm_os_window_close=0 sh -c "$command"
fi
