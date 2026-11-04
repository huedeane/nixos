#!/usr/bin/env bash

# No argument: drag an area and start recording, or if already recording, save it as a GIF
# and copy it. While recording (binds in hyprland.lua): `save` (Ctrl+S) saves without
# copying, `copy` (Ctrl+C) saves and copies, `cancel` (Esc) throws it away.

mode=${1:-toggle}

dir="$HOME/Videos/Recordings"
state="${XDG_RUNTIME_DIR:-/tmp}/screen-gif"
pidfile="$state/pid"
video="$state/recording.mp4"

# Red outline around the recorded area, drawn by ags just outside it
border() {
  ags request record-border "$@" >/dev/null 2>&1 || true
}

notify() {
  notify-send -a "screen-gif" -h string:x-dunst-stack-tag:screen-gif "$@"
}

recording() {
  [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null
}

stop() {
  pid=$(cat "$pidfile")
  kill -INT "$pid"
  while kill -0 "$pid" 2>/dev/null; do sleep 0.1; done
  rm -f "$pidfile"
  border hide
}

if [ "$mode" = "cancel" ]; then
  recording || exit 0
  stop
  rm -f "$video"
  notify "Recording" "Recording cancelled" --urgency=low --expire-time=2000
  exit 0
fi

if recording; then
  stop
  [ "$mode" = save ] && copy=false || copy=true

  mkdir -p "$dir"
  gif="$dir/$(date +%Y-%m-%d_%H-%M-%S).gif"
  notify "Recording" "Converting to GIF..." --expire-time=0

  # Drop unchanged frames (idle stretches otherwise become 1x1 GIF frames that break
  # kitty previews) and keep real timing with vfr; two-pass palette keeps colours
  # accurate; cap width so files stay shareable
  if ! ffmpeg -loglevel error -y -i "$video" \
    -vf "fps=15,mpdecimate,scale='min(1280,iw)':-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5" \
    -fps_mode vfr \
    "$gif"; then
    notify "Recording" "GIF conversion failed" --urgency=critical
    exit 1
  fi
  rm -f "$video"

  summary="$(basename "$gif") · $(du -h "$gif" | cut -f1)"
  if $copy; then
    wl-copy --type text/uri-list "file://$gif"
    summary="$summary · copied"
  fi
  action=$(notify "Recording saved" "$summary" \
    --category=x-success \
    --icon="$gif" \
    --action="open=Open" \
    --action="folder=Show in folder")
  case "$action" in
  open) xdg-open "$gif" ;;
  folder) xdg-open "$dir" ;;
  esac
  exit 0
fi

# save/copy only mean something while a recording is running
[ "$mode" = toggle ] || exit 0

mkdir -p "$state"
geometry=$(slurp -d) || exit 0
IFS=', x' read -r x y w h <<<"$geometry"
border show "$x" "$y" "$w" "$h"
rm -f "$video"
wf-recorder -g "$geometry" -f "$video" >/dev/null 2>&1 &
echo $! >"$pidfile"
disown
