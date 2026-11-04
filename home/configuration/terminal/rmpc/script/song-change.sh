#!/usr/bin/env sh

dir=$(dirname "$0")

# Playing a song with Enter can fire the hook twice for the same song, so ignore
# a repeat of the last song within a few seconds
last="${XDG_RUNTIME_DIR:-/tmp}/rmpc-song-change"
now=$(date +%s)
if [ -f "$last" ]; then
  { read -r prev_time; read -r prev_file; } < "$last"
  [ "$prev_file" = "$FILE" ] && [ $((now - prev_time)) -lt 5 ] && exit 0
fi
printf '%s\n%s\n' "$now" "$FILE" > "$last"

# 1- and 2-star songs get skipped automatically (ags media widget), so don't count them as
# played, unless skipping is turned off (right-click the music widget)
skip_off="${XDG_STATE_HOME:-$HOME/.local/state}/ags/skip-low-rated-off"
rating=$(rmpc sticker get "$FILE" "rating" 2>/dev/null | jq -r '.value')
if [ -f "$skip_off" ]; then
  "$dir/playcount.sh"
else
  case $rating in
  1 | 2) ;;
  *) "$dir/playcount.sh" ;;
  esac
fi

"$dir/albumrating.sh"
