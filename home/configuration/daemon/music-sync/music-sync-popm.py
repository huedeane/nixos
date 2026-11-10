# Write MPD rating stickers into the mp3s' POPM (popularimeter) frame.
# Reads "<uri>\t<rating 1-5>" lines on stdin, uri relative to the music dir in argv[1].
# Uses the MusicBee email and star scale the library was already tagged with, keeps the
# frame's play counter, and only rewrites files whose rating actually changed.
import os
import sys

from mutagen.id3 import ID3, POPM, ID3NoHeaderError

EMAIL = "MusicBee"
STARS = {1: 1, 2: 64, 3: 128, 4: 196, 5: 255}

music_dir = sys.argv[1]
updated = 0
for line in sys.stdin:
    uri, _, value = line.rstrip("\n").rpartition("\t")
    try:
        rating = STARS[int(float(value))]
    except (ValueError, KeyError):
        continue
    path = os.path.join(music_dir, uri)
    if not uri.lower().endswith(".mp3") or not os.path.isfile(path):
        continue
    try:
        tags = ID3(path)
    except ID3NoHeaderError:
        tags = ID3()
    except Exception as e:
        print(f"popm: skipping {uri}: {e}", file=sys.stderr)
        continue

    frame = next((p for p in tags.getall("POPM") if p.email == EMAIL), None)
    if frame is not None and frame.rating == rating:
        continue
    count = getattr(frame, "count", 0) if frame is not None else 0
    tags.delall(f"POPM:{EMAIL}")
    tags.add(POPM(email=EMAIL, rating=rating, count=count))

    # Keep the file's ID3 version (some are 2.3, which older players need)
    if tags.version[:2] == (2, 3):
        tags.update_to_v23()
        tags.save(path, v2_version=3)
    else:
        tags.save(path)
    updated += 1

if updated:
    print(f"popm: updated rating on {updated} file(s)")
