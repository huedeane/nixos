#!/usr/bin/env bash
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

while [ ! -S "$SOCK" ]; do sleep 0.5; done

socat -U - "UNIX-CONNECT:$SOCK" | while read -r line; do
  case "$line" in
    monitoradded*|monitorremoved*)
      sleep 3
      ags quit 2>/dev/null
      sleep 3
      uwsm app -- ags run
      ;;
  esac
done
