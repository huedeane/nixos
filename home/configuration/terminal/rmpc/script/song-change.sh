#!/usr/bin/env sh

dir=$(dirname "$0")

# 1-star songs get skipped automatically (ags media widget), so don't count them as played
rating=$(rmpc sticker get "$FILE" "rating" 2>/dev/null | jq -r '.value')
[ "$rating" = "1" ] || "$dir/playcount.sh"

"$dir/albumrating.sh"
