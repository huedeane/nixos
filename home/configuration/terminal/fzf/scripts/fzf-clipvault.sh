#!/bin/sh

set -eu

COPY=${CLIPVAULT_COPY:-"wl-copy"}

PREVIEW='
    f=$(mktemp) || exit
    printf %s {} | clipvault get >"$f" 2>/dev/null
    fzf-preview.sh "$f"
    rm -f "$f"
'

TAB=$(printf '\t')


# Clear all: confirm, then delete every entry, then refresh the list.
CLEAR='
    printf "Clear clipboard history? [y/N] " > /dev/tty
    read -r ans < /dev/tty
    case "$ans" in
        [Yy]*) clipvault list | while IFS= read -r l; do
                   printf %s "$l" | clipvault delete
               done ;;
    esac
'

clipvault list | fzf \
  --no-sort \
  --border-label=" Clipboard History " \
  --delimiter="$TAB" \
  --with-nth=2.. \
  --header-label=' Help ' \
  --header='enter: copy   ctrl-d: delete   ctrl-x: clear all   esc: quit' \
  --preview-label=" Preview " \
  --preview="$PREVIEW" \
  --bind="esc:become(true)" \
  --bind="enter:execute-silent(printf %s {} | clipvault get | $COPY)" \
  --bind='ctrl-d:execute-silent(printf %s {} | clipvault delete)+reload(clipvault list)' \
  --bind="ctrl-x:execute($CLEAR)+reload(clipvault list)"
