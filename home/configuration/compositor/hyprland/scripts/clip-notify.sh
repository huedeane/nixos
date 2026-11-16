#!/usr/bin/env sh
# Skip the first GRACE seconds: KDE Connect pushes the phone's clipboard at login,
# and again whenever the phone reconnects later on
GRACE=10
STAMP="${XDG_RUNTIME_DIR:-/tmp}/clip-notify-kdeconnect"

if [ "$1" != "notify" ]; then
  export CLIP_NOTIFY_START="$(date +%s)"
  # Stamp every KDE Connect (re)connect so the phone's clipboard push stays quiet
  dbus-monitor --session "type='signal',interface='org.kde.kdeconnect.device',member='reachableChanged'" \
    "type='signal',interface='org.kde.kdeconnect.device',member='linksChanged'" |
    while read -r line; do
      case "$line" in signal*) date +%s >"$STAMP" ;; esac
    done &
  exec wl-paste --type text --watch "$0" notify
fi

cat >/dev/null
[ "$CLIPBOARD_STATE" = data ] || exit 0
now=$(date +%s)
[ $((now - CLIP_NOTIFY_START)) -ge "$GRACE" ] || exit 0
[ $((now - $(cat "$STAMP" 2>/dev/null || echo 0))) -ge "$GRACE" ] || exit 0
notify-send -a clipboard -h string:x-dunst-stack-tag:clipboard System "Copied to Clipboard" --expire-time=1500
