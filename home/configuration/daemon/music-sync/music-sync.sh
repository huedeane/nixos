#!/usr/bin/env bash
# Two-way sync of ~/Music with the NAS. Music files go through unison; MPD's sticker DB
# (play counts/ratings) is merged row by row (see below), and song ratings are written into
# the mp3s' POPM tags.
set -euo pipefail

local_dir="$HOME/Music"
nas_dir="/mnt/nas/Music"
local_db="$local_dir/sticker.sql"
nas_db="$nas_dir/sticker.sql"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/music-sync"
mpd_socket="$XDG_RUNTIME_DIR/mpd/socket"

mkdir -p "$state_dir" "$local_dir"
exec 9>"$state_dir/lock"
flock -n 9 || { echo "music-sync already running"; exit 0; }

# Away from home (or NAS not mounted yet): nothing to do, catch up next run
if ! mountpoint -q /mnt/nas || [ ! -d "$nas_dir" ]; then
  echo "NAS not mounted, skipping"
  exit 0
fi

# ---- Sticker DB ----
# Merged row by row into the local DB in place (MPD keeps it open, so it is never replaced):
# play counts take the higher of the two sides, other stickers (ratings) take the NAS value
# only if this machine hasn't changed it since the last sync, stickers on one side only are kept.
# The merged result is then copied to the NAS, and kept as the base for the next sync.
base_db="$state_dir/sticker.base.sql"

# Hash the rows rather than the file, so page layout differences don't count as changes
db_hash() {
  [ -f "$1" ] || { echo none; return; }
  sqlite3 -readonly "$1" "select type, uri, name, value from sticker order by 1, 2, 3" | sha256sum | cut -d' ' -f1
}

if [ -f "$local_db" ] && [ -f "$nas_db" ]; then
  cp "$nas_db" "$state_dir/nas.sql"
  # No base yet (first sync): an empty one, so this machine's ratings win where they differ
  [ -f "$base_db" ] || sqlite3 "$base_db" "create table sticker(type, uri, name, value)"
  sqlite3 "$local_db" <<SQL
.timeout 10000
attach '$state_dir/nas.sql' as n;
attach '$base_db' as b;
begin immediate;
insert into main.sticker
  select * from n.sticker as x
  where not exists (select 1 from main.sticker as m
                    where m.type = x.type and m.uri = x.uri and m.name = x.name);
update main.sticker as m set value = x.value
  from n.sticker as x
  where x.type = m.type and x.uri = m.uri and x.name = m.name
    and m.name = 'playCount'
    and cast(x.value as integer) > cast(m.value as integer);
update main.sticker as m set value = x.value
  from n.sticker as x
  left join b.sticker as o on o.type = x.type and o.uri = x.uri and o.name = x.name
  where x.type = m.type and x.uri = m.uri and x.name = m.name
    and m.name != 'playCount'
    and x.value != m.value
    and m.value is o.value;
commit;
SQL
  rm -f "$state_dir/nas.sql"
elif [ -f "$nas_db" ]; then
  # Fresh machine: nothing to merge with, take the NAS copy (MPD isn't using a file yet)
  cp "$nas_db" "$local_db"
fi

if [ -f "$local_db" ]; then
  sqlite3 "$local_db" ".backup '$state_dir/merged.sql'"
  if [ "$(db_hash "$local_db")" != "$(db_hash "$nas_db")" ]; then
    cp "$state_dir/merged.sql" "$nas_db.tmp"
    mv -f "$nas_db.tmp" "$nas_db"
    echo "stickers: merged and pushed to NAS"
  fi
  mv -f "$state_dir/merged.sql" "$base_db"
fi

# ---- Ratings -> mp3 tags ----
# Write each song's rating sticker into its POPM tag, before unison so retagged files go
# to the NAS in this same run (songs only on the NAS yet get theirs on the next run)
if [ -f "$local_db" ]; then
  sqlite3 -readonly -separator $'\t' "$local_db" \
    "select uri, value from sticker where type = 'song' and name = 'rating'" \
    | music-sync-popm "$local_dir"
fi

# ---- Music files ----
unison "$local_dir" "$nas_dir" \
  -batch -auto -times -prefer newer \
  -perms 0 -dontchmod -links false -ignoreinodenumbers -fastcheck true \
  -ignore 'Name sticker.sql' -ignore 'Name sticker.sql-journal' \
  -ignore 'Name sticker.sql.*' -ignore 'Name .unison*' \
  -logfile "$state_dir/unison.log"

# Let MPD pick up added/removed songs (only if it's already running)
if systemctl --user is-active -q mpd.service; then
  printf 'update\nclose\n' | socat - "UNIX-CONNECT:$mpd_socket" >/dev/null || true
fi
