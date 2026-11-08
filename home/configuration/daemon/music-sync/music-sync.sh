#!/usr/bin/env bash
# Two-way sync of ~/Music with the NAS. Music files go through unison; MPD's sticker DB
# (play counts/ratings) is copied whole, newest change wins, with MPD stopped while it's
# replaced so MPD never keeps writing to a deleted file.
set -euo pipefail

local_dir="$HOME/Music"
nas_dir="/mnt/nas/Music"
local_db="$local_dir/sticker.sql"
nas_db="$nas_dir/sticker.sql"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/music-sync"
last_file="$state_dir/sticker.last"
mpd_socket="$XDG_RUNTIME_DIR/mpd/socket"

mkdir -p "$state_dir" "$local_dir"
exec 9>"$state_dir/lock"
flock -n 9 || { echo "music-sync already running"; exit 0; }

# Away from home (or NAS not mounted yet): nothing to do, catch up next run
if ! mountpoint -q /mnt/nas || [ ! -d "$nas_dir" ]; then
  echo "NAS not mounted, skipping"
  exit 0
fi

# ---- Music files ----
unison "$local_dir" "$nas_dir" \
  -batch -auto -times -prefer newer \
  -perms 0 -dontchmod -links false -ignoreinodenumbers -fastcheck true \
  -ignore 'Name sticker.sql' -ignore 'Name sticker.sql-journal' \
  -ignore 'Name sticker.sql.*' -ignore 'Name .unison*' \
  -logfile "$state_dir/unison.log"

# ---- Sticker DB ----
# Hash the rows rather than the file, so page layout differences don't count as changes
db_hash() {
  [ -f "$1" ] || { echo none; return; }
  sqlite3 -readonly "$1" "select type, uri, name, value from sticker order by 1, 2, 3" | sha256sum | cut -d' ' -f1
}

push() {
  sqlite3 "$local_db" ".backup '$state_dir/push.sql'"
  cp "$state_dir/push.sql" "$nas_db.tmp"
  mv -f "$nas_db.tmp" "$nas_db"
  rm -f "$state_dir/push.sql"
  echo "stickers: pushed local -> NAS"
}

pull() {
  cp "$nas_db" "$state_dir/pull.sql"
  local was_active=0
  systemctl --user is-active -q mpd.service && was_active=1
  systemctl --user stop mpd.socket mpd.service
  mv -f "$state_dir/pull.sql" "$local_db"
  systemctl --user start mpd.socket
  [ "$was_active" = 1 ] && systemctl --user start mpd.service
  echo "stickers: pulled NAS -> local"
}

local_hash=$(db_hash "$local_db")
nas_hash=$(db_hash "$nas_db")
last_hash=$(cat "$last_file" 2>/dev/null || echo none)

if [ "$local_hash" = "$nas_hash" ]; then
  :
elif [ "$nas_hash" = none ] || [ "$nas_hash" = "$last_hash" ]; then
  push
elif [ "$local_hash" = none ] || [ "$local_hash" = "$last_hash" ]; then
  pull
else
  # Both sides changed since the last sync: keep the newer file, back up the other
  backup="$state_dir/sticker-conflict-$(date +%Y%m%d-%H%M%S).sql"
  if [ "$(stat -c %Y "$local_db")" -ge "$(stat -c %Y "$nas_db")" ]; then
    cp "$nas_db" "$backup"
    push
    kept="this machine's"
  else
    sqlite3 "$local_db" ".backup '$backup'"
    pull
    kept="the NAS"
  fi
  notify-send -a music-sync "Music Sync" \
    "Play counts changed on both machines; kept $kept copy. Other saved to $backup" || true
fi
db_hash "$local_db" > "$last_file"

# Let MPD pick up added/removed songs (only if it's already running)
if systemctl --user is-active -q mpd.service; then
  printf 'update\nclose\n' | socat - "UNIX-CONNECT:$mpd_socket" >/dev/null || true
fi
