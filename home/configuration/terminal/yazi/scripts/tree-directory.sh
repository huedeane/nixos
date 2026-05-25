#!/usr/bin/env sh
System="${1:-System}"

 tree -f -i $(pwd) | 
  sed "s|$(pwd)/|./|g"|
  wl-copy

dunstify \
  "$System" \
  "File directory tree copied to clipboard!"
