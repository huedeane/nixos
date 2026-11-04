#!/usr/bin/env sh

# Keep an "albumRating" sticker on every song in the current song's album: the average of
# the rated songs in the album folder, leaving out 1-star songs, counting 2-star songs as
# 1 and 5-star songs as 6 so they weigh more (capped at 5).

[ -n "$FILE" ] || exit 0
album=$(dirname "$FILE")

average=$(rmpc sticker find "$album" "rating" 2>/dev/null |
  jq -r '[.[].value | tonumber | select(. != 1) | if . == 5 then 6 elif . == 2 then 1 else . end]
    | if length > 0 then (add / length | [., 5] | min | . * 10 | round / 10 | tostring) else empty end')
[ -n "$average" ] || exit 0

current=$(rmpc sticker get "$FILE" "albumRating" 2>/dev/null | jq -r '.value')
[ "$current" = "$average" ] && exit 0

rmpc listall "$album" | while IFS= read -r song; do
  rmpc sticker set "$song" "albumRating" "$average"
done
