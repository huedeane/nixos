#!/usr/bin/env sh
# Skip the first GRACE seconds: KDE Connect pushes the phone's clipboard at login
GRACE=10

if [ "$1" != "notify" ]; then
  export CLIP_NOTIFY_START="$(date +%s)"
  exec wl-paste --type text --watch "$0" notify
fi

cat >/dev/null
[ "$CLIPBOARD_STATE" = data ] || exit 0
[ $(($(date +%s) - CLIP_NOTIFY_START)) -ge "$GRACE" ] || exit 0
notify-send -a clipboard -h string:x-dunst-stack-tag:clipboard System "Copied to Clipboard" --expire-time=1500
