#!/usr/bin/env sh
System="${1:-System}"

tree -f |
  grep '─' |
  awk '{print $NF}' |
  wl-copy

dunstify \
  "$System" \
  "File directory tree copied to clipboard!"
