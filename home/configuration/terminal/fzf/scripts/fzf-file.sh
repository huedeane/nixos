#!/usr/bin/env sh
fzf \
  --preview-label=" Preview " \
  --preview-border=sharp \
  --preview 'fzf-preview.sh {}' \
  --bind 'focus:transform-preview-label:[[ -n {} ]] && printf " Previewing [%s] " {}' \
  --header-label=" File Type " \
  --header-border=sharp \
  --bind 'focus:transform-header:file --brief {} || echo "No file selected"' \
  "$@"
