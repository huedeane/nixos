#!/usr/bin/env bash
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
DEBOUNCE=6

while [ ! -S "$SOCK" ]; do sleep 0.5; done

pid=""
socat -U - "UNIX-CONNECT:$SOCK" | while read -r line; do
  case "$line" in
    monitoradded*|monitorremoved*)
      [ -n "$pid" ] && kill "$pid" 2>/dev/null
      { sleep "$DEBOUNCE"; hyprctl reload; ags-restart.sh; } &
      pid=$!
      ;;
  esac
done
