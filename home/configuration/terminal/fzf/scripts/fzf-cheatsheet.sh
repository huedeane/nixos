#!/usr/bin/env sh
set -eu
CHEAT_DIR="$HOME/.config/nixos/home/configuration/terminal/fzf/data"
export CHEAT_DIR          # so the fzf ctrl-e child process can see it

CMD="${1:-${CALLER_TTY:-}}"
case "$CMD" in
  /dev/*|pts/*) CMD=$(detect-foreground.sh "$CMD") ;;
esac
[ "$CMD" = "cava" ] && CMD="rmpc"
filter="$CMD"

# --- Validate JSON ---
for f in "$CHEAT_DIR"/*.json; do
  [ -e "$f" ] || continue
  if ! jq empty "$f" >/dev/null 2>&1; then
    echo "Error: invalid JSON in $f" >&2
    exit 1
  fi
done

# --- Grab json and convert to TSV ---
build() {
  for f in "$CHEAT_DIR"/*.json; do
    [ -e "$f" ] || continue
    program=$(basename "$f" .json)
    jq -r --arg program "$program" '
      .[]
      | [ $program,
          (.mode // ""),
          (.keys // ""),
          ((.tags // []) | join(", ")),
          (.description // "") ]
      | @tsv
    ' "$f"
  done
}

# --- Decide whether the requested group has any entries ---
DATA=$(build)
no_match=0
if [ -n "$filter" ] && ! printf '%s\n' "$DATA" | cut -f1 | grep -Fxq "$filter"; then
  no_match=1
fi

# --- Build display list (drops Group when filtering, drops Mode when all empty) ---
# Output fields:  1=display line   2=group   3=description
display() {
  cols=$(tput cols </dev/tty 2>/dev/null || echo 80)
  OFFSET=10
  width=$((cols > OFFSET ? cols - OFFSET : cols))
  printf '%s\n' "$DATA" | awk -F'\t' -v filter="$filter" -v width="$width" -v cheatdir="$CHEAT_DIR" '
    BEGIN {
      wp = length("Group"); wm = length("Mode")
      wk = length("Keys");  wd = length("Description")
    }
    {
      if (filter != "" && $1 != filter) next
      n++
      prog[n]=$1; mode[n]=$2; keys[n]=$3; tags[n]=$4; desc[n]=$5
      if (length($1) > wp) wp = length($1)
      if (length($2) > wm) wm = length($2)
      if (length($3) > wk) wk = length($3)
      if (length($5) > wd) wd = length($5)
    }
    END {
      if (filter != "" && n == 0) {
        msg = sprintf("No Keybind for %s was found", filter)
        pad = int((width - length(msg)) / 2)
        if (pad < 0) pad = 0
        printf "%*s%s\n", pad, "", msg
        exit
      } else {
        show_group = (filter == "")
        show_mode = 0
      }
      for (i = 1; i <= n; i++) if (mode[i] != "") { show_mode = 1; break }
      # Header (single field, no hidden cols)
      h = ""
      if (show_group) h = h sprintf("%-*s  ", wp, "Group")
      if (show_mode)  h = h sprintf("%-*s  ", wm, "Mode")
      h = h sprintf("%-*s  ", wk, "Keys")
      h = h sprintf("%-*s  ", wd, "Description")
      h = h "Tags"
      print h
      # Rows: display \t group \t description
      for (i = 1; i <= n; i++) {
        line = ""
        if (show_group) line = line sprintf("%-*s  ", wp, prog[i])
        if (show_mode)  line = line sprintf("%-*s  ", wm, mode[i])
        line = line sprintf("%-*s  ", wk, keys[i])
        line = line sprintf("%-*s  ", wd, desc[i])
        line = line tags[i]
        printf "%s\t%s\t%s\n", line, (cheatdir "/" prog[i] ".json"), desc[i]
      }
    }
  '
}

# --- Border label ---
if [ -n "$filter" ]; then
  label=" Keybind for $filter "
else
  label=" Keybind "
fi

# --- Fzf options ---
set -- \
  --layout=reverse-list \
  --border-label="$label" \
  --prompt='> ' \
  --header-lines=1 \
  --list-label='' \
  --bind 'result:transform-list-label:echo ""' \
  --bind 'ctrl-e:execute(ln=$(grep -nF -- {3} {2} | head -1 | cut -d: -f1); nvim "+${ln:-1}" {2})' \
  --ellipsis='...' \
  --delimiter='\t' \
  --exact \
  --with-nth=1

if [ "$no_match" -eq 1 ]; then
  set -- "$@" \
    --header-border=vertical \
    --color="header:#292c3c,header-bg:#e78284,header-border:#e78284"
else
  set -- "$@" --header-border=none
fi

# --- Display fzf ---
selected=$(display | fzf "$@") || exit 0
[ -z "$selected" ] && exit 0
