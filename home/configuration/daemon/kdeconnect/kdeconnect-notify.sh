# Listens for kdeconnectd's shareReceived D-Bus signal and pops a notification per received file

device=""
pending=0
dbus-monitor --session "type='signal',interface='org.kde.kdeconnect.device.share',member='shareReceived'" |
  while read -r line; do
    case "$line" in
      signal*member=shareReceived*)
        # path=/modules/kdeconnect/devices/<id>/share
        id=${line#*path=/modules/kdeconnect/devices/}
        id=${id%%/*}
        device=$(busctl --user get-property org.kde.kdeconnect "/modules/kdeconnect/devices/$id" \
          org.kde.kdeconnect.device name 2>/dev/null | sed -E 's/^s "(.*)"$/\1/')
        pending=1
        ;;
      # dbus-monitor also prints its own NameAcquired etc. on startup; only the arg of shareReceived is a file
      signal* | method* | error*) pending=0 ;;
      string\ \"*)
        [ "$pending" = 1 ] || continue
        pending=0
        url=${line#string \"}
        url=${url%\"}
        file=${url#file://}
        file=$(printf '%b' "${file//%/\\x}")
        name=$(basename "$file")

        icon=kdeconnect
        case "${name,,}" in
          *.jpg | *.jpeg | *.png | *.webp | *.gif) icon=$file ;;
        esac

        (
          action=$(notify-send -a "KDE Connect" -i "$icon" -A open=Open -A folder="Show in folder" \
            "File from ${device:-phone}" "$name")
          case "$action" in
            open) xdg-open "$file" ;;
            folder) xdg-open "$(dirname "$file")" ;;
          esac
        ) &
        ;;
    esac
  done
