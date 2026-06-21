#!/usr/bin/env sh
tty="${1#/dev/}"
ps -t "$tty" -o stat=,comm= | awk 'index($1,"+"){print $2}' | tail -1
