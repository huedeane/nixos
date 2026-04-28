#!/usr/bin/env sh

case "$1" in
*"password for"*) msg="System" ;;
*) msg="${1:-System}" ;;
esac

prompt="Password"
message="<b><span foreground='#e78284'>$msg</span></b> requesting administrative privilege"

printf '' | rofi -dmenu -p "$prompt" -password -no-fixed-num-lines -mesg "$message"
