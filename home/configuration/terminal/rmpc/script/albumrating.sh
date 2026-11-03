#!/usr/bin/env sh

# Keep an "albumRating" sticker (average of the rated songs in the album folder)
# on every song in the current song's album.

[ -n "$FILE" ] || exit 0
album=$(dirname "$FILE")

average=$(rmpc sticker find "$album" "rating" 2>/dev/null |
  jq -r '[.[].value | tonumber] | if length > 0 then (add / length * 10 | round / 10 | tostring) else empty end')
[ -n "$average" ] || exit 0

current=$(rmpc sticker get "$FILE" "albumRating" 2>/dev/null | jq -r '.value')
[ "$current" = "$average" ] && exit 0

rmpc listall "$album" | while IFS= read -r song; do
  rmpc sticker set "$song" "albumRating" "$average"
done
