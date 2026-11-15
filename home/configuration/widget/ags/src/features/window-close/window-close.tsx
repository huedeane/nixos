import { createState } from "ags"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import GLib from "gi://GLib"
import app from "ags/gtk4/app"
import Hyprland from "gi://AstalHyprland"
import { pointer } from "../../lib/utils"
import style from "./window-close.scss"

app.apply_css(style)

const SIZE = 29
const ICON = "\u{f00d}"
const LAVENDER = "#babbf1"
const RED = "#e78284"

type Target = { address: string; monitor: string; x: number; y: number } | null

const hypr = Hyprland.get_default()
const [target, setTarget] = createState<Target>(null)

// hyprctl reports where a window is headed, not where it is mid-animation, so the button would
// sit at the final corner while the window is still sliding in. Hide it whenever the target
// changes and only show it once it has held for the windowsMove animation (speed 6 = 600ms).
const SETTLE_MS = 600
let sample = ""
let sampleAt = 0
let last = ""
const update = (next: Target) => {
  const json = JSON.stringify(next)
  const now = GLib.get_monotonic_time() / 1000
  if (json !== sample) {
    sample = json
    sampleAt = now
  }
  const settled = now - sampleAt >= SETTLE_MS
  const shown = settled ? next : null
  const shownJson = settled ? json : "null"
  if (shownJson === last) return
  last = shownJson
  setTarget(shown)
}

const fetchTarget = () =>
  execAsync(["hyprctl", "activewindow", "-j"])
    .then((out) => {
      const w = JSON.parse(out)
      const monitor = hypr.get_monitor(w.monitor)
      if (!w.address || !monitor || w.fullscreen === 2) return update(null)
      update({
        address: w.address,
        monitor: monitor.name,
        x: w.at[0] + w.size[0] + 1 - monitor.x,
        y: w.at[1] - 2 - monitor.y,
      })
    })
    .catch(() => update(null))

let pending = 0
const refresh = () => {
  if (pending) return
  pending = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 30, () => {
    pending = 0
    fetchTarget()
    return GLib.SOURCE_REMOVE
  })
}

hypr.connect("event", refresh)
refresh()

// Column resizes (colresize/fit, mouse drags) send no IPC event, so poll as well; otherwise
// the button stays at the corner the window had before the resize. Fast enough that the
// button reappears promptly once the animation ends.
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => {
  fetchTarget()
  return GLib.SOURCE_CONTINUE
})

const close = (address: string) =>
  execAsync([
    "hyprctl",
    "dispatch",
    `hl.dsp.window.close({ window = "address:${address}" })`,
  ]).catch(console.error)

export default function WindowClose(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT } = Astal.WindowAnchor
  const [hovered, setHovered] = createState(false)

  const here = target((t) => (t?.monitor === gdkmonitor.connector ? t : null))

  // A cursor warp never sends the button a leave event, so drop the hover whenever focus
  // moves; motion over the button turns it back on
  hypr.connect("event", (_, event) => {
    if (event === "activewindowv2" || event === "workspacev2" || event === "focusedmonv2") setHovered(false)
  })

  return (
    <window
      visible={here((t) => t !== null)}
      namespace="window-close"
      cssClasses={["window-close"]}
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.NONE}
      anchor={TOP | LEFT}
      marginLeft={here((t) => (t?.x ?? 0) - (SIZE - 1) / 2)}
      marginTop={here((t) => (t?.y ?? 0) - (SIZE - 1) / 2)}
      application={app}
    >
      <box
        cursor={pointer}
        cssClasses={hovered((h) => (h ? ["dot", "hover"] : ["dot"]))}
        widthRequest={SIZE}
        heightRequest={SIZE}
      >
        <Gtk.EventControllerMotion
          onEnter={() => setHovered(true)}
          onMotion={() => setHovered(true)}
          onLeave={() => setHovered(false)}
        />
        <Gtk.GestureClick
          onReleased={() => {
            const t = target.peek()
            if (t) close(t.address)
          }}
        />
        <label
          hexpand
          halign={Gtk.Align.CENTER}
          useMarkup
          label={hovered((h) => `<b><span foreground="${h ? RED : LAVENDER}">${ICON}</span></b>`)}
        />
      </box>
    </window>
  )
}
