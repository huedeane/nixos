#!/usr/bin/env sh
set -eu

COMMAND_FILE="$HOME/.config/nixos/home/configuration/terminal/fzf/data/commands/linux.json"
export COMMAND_FILE

build() {
  jq -r '
    .[]
    | [ (.command // ""),
        (.description // ""),
        ((.tags // []) | join(", ")) ]
    | @tsv
  ' "$COMMAND_FILE"
}

display() {
  build | awk -F'\t' '
    BEGIN {
      wd = length("Description"); wc = length("Command")
    }
    {
      n++
      cmd[n]=$1; desc[n]=$2; tags[n]=$3
      if (length($1) > wc) wc = length($1)
      if (length($2) > wd) wd = length($2)
    }
    END {
      printf "%-*s   %-*s   %s\n", wd, "Description", wc, "Command", "Tags"
      for (i = 1; i <= n; i++) {
        printf "%-*s │ %-*s │ %s\t%s\n", wd, desc[i], wc, cmd[i], tags[i], cmd[i]
      }
    }
  '
}

COPY_CMD=$(
  if   command -v wl-copy >/dev/null 2>&1; then echo 'wl-copy'
  else echo ''
  fi
)
export COPY_CMD

selected=$(display | fzf \
  --layout=reverse-list \
  --border-label=' Commands ' \
  --prompt='> ' \
  --header-lines=1 \
  --header-border=none \
  --list-label='' \
  --bind 'result:transform-list-label:echo ""' \
  --bind 'ctrl-e:execute(ln=$(grep -nF -- {2} "$COMMAND_FILE" | head -1 | cut -d: -f1); nvim "+${ln:-1}" "$COMMAND_FILE")' \
  --bind 'enter:execute-silent(printf "%s" {2} | ${COPY_CMD:-cat >/dev/null})+abort' \
  --ellipsis='...' \
  --delimiter='\t' \
  --exact \
  --with-nth=1) || exit 0

[ -z "$selected" ] && exit 0
