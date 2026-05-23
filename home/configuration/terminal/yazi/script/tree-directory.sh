#!/usr/bin/env sh

tree -f |
  grep '─' |
  awk '{print $NF}' |
  wl-copy |
  dunstify \
    "Yazi" \
    "File directory tree copied to clipboard!"
