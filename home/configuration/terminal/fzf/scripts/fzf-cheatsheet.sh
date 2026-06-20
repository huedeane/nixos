#!/bin/sh
set -eu

CHEAT_DIR="${1:-../data}"

# --- Validate Json ---
for f in "$CHEAT_DIR"/*.json; do
  [ -e "$f" ] || continue
  if ! jq empty "$f" >/dev/null 2>&1; then
    echo "Error: invalid JSON in $f" >&2
    exit 1
  fi
done

# --- Grab json and convert ---
build() {
  for f in "$CHEAT_DIR"/*.json; do
    [ -e "$f" ] || continue
    program=$(basename "$f" .json)
    jq -r --arg program "$program" '
      .[]
      | [ $program,
          (.keys // ""),
          ((.tags // []) | join(",")),
          (.description // "") ]
      | @tsv
    ' "$f"
  done
}

# --- Build display list ---
display() {
  build | awk -F'\t' '
    BEGIN {
      wp = length("GROUP"); wk = length("KEYS")
      wt = length("TAGS");  wd = length("DESCRIPTION")
    }
    {
      prog[NR]=$1; keys[NR]=$2; tags[NR]=$3; desc[NR]=$4
      if (length($1) > wp) wp = length($1)
      if (length($2) > wk) wk = length($2)
      if (length($3) > wt) wt = length($3)
      if (length($4) > wd) wd = length($4)
    }
    END {
      printf "%-*s  %-*s  %-*s  %s\n", \
        wp, "Group", wk, "Keys", wd, "Description", "Tags"
      for (i = 1; i <= NR; i++)
        printf "%-*s  %-*s  %-*s  %s\t%s\t%s\n", \
          wp, prog[i], wk, keys[i], wd, desc[i], tags[i], keys[i], desc[i]
    }
  '
}

# --- Display fzf ---
selected=$(
  display \
    | fzf \
        --layout=reverse-list \
        --border-label=" Keybinding " \
        --prompt='> ' \
        --header-lines=1 \
        --header-border=none \
        --list-label='' \
        --bind 'result:transform-list-label:echo ""' \
        --ellipsis='' \
        --list-label='' \
        --delimiter='\t' \
        --with-nth=1 \
) || exit 0
 
[ -z "$selected" ] && exit 0
