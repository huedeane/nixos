#!/usr/bin/env bash
ags quit 2>/dev/null
sleep 0.5
uwsm app -- ags run
notify-send -a ags 'AGS' 'Restarted' --expire-time=1500
