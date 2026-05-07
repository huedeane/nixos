#!/usr/bin/env sh

wl-paste --watch sh -c '
    CONTENT=$(wl-paste)
    case "$CONTENT" in
        *wl-paste*) ;;
        *) [ -n "$CONTENT" ] && clipvault store --max-entries 100 --max-entry-age 1d && notify-send "System" "Copied to Clipboard" --expire-time=1500 ;;
    esac
'
