import { createState } from "ags"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import GLib from "gi://GLib"
import app from "ags/gtk4/app"
import Hyprland from "gi://AstalHyprland"
import { pointer } from "../../lib/utils"
import style from "./column-peek.scss"

app.apply_css(style)

// Matches general.border_size, so the strip also covers the neighbour's border
const BORDER = 3
const CHEVRON = { left: "\u{f053}", right: "\u{f054}" }

type Side = "left" | "right"
// mw/mh: the monitor's logical size, for the right/bottom margins
type Peek = { address: string; x: number; y: number; w: number; h: number; mw: number; mh: number }
type Peeks = Record<string, Partial<Record<Side, Peek>>>

const hypr = Hyprland.get_default()
const [peeks, setPeeks] = createState<Peeks>({})

// Scrolling-layout neighbours that hang off the left/right edge of each monitor
const findPeeks = (monitors: any[], clients: any[]): Peeks => {
  const result: Peeks = {}
  for (const m of monitors) {
    const sides: Partial<Record<Side, Peek>> = {}
    result[m.name] = sides
    if (m.specialWorkspace?.name) continue

    const left = m.x
    const right = m.x + m.width / m.scale
    const tiled = clients.filter(
      (c) => c.mapped && !c.hidden && c.workspace.id === m.activeWorkspace.id && !c.floating,
    )
    if (tiled.some((c) => c.fullscreen > 0)) continue

    for (const c of tiled) {
      const x0 = c.at[0] - BORDER
      const x1 = c.at[0] + c.size[0] + BORDER
      const box = {
        address: c.address,
        y: c.at[1] - BORDER - m.y,
        h: c.size[1] + BORDER * 2,
        mw: m.width / m.scale,
        mh: m.height / m.scale,
      }
      if (x0 < left && x1 > left) sides.left = { ...box, x: 0, w: x1 - left }
      if (x0 < right && x1 > right) sides.right = { ...box, x: x0 - left, w: right - x0 }
    }
  }
  return result
}

// hyprctl reports where windows are headed, not where they are mid-animation, so strips would
// sit at their final spots while the columns are still sliding. Hide them whenever the layout
// changes and only show them once it has held for the windowsMove animation (speed 6 = 600ms).
const SETTLE_MS = 600
let sample = ""
let sampleAt = 0
let last = ""
const update = (next: Peeks) => {
  const json = JSON.stringify(next)
  const now = GLib.get_monotonic_time() / 1000
  if (json !== sample) {
    sample = json
    sampleAt = now
  }
  const settled = now - sampleAt >= SETTLE_MS
  const shownJson = settled ? json : "{}"
  if (shownJson === last) return
  last = shownJson
  setPeeks(settled ? next : {})
}

const fetchPeeks = () =>
  Promise.all([execAsync(["hyprctl", "monitors", "-j"]), execAsync(["hyprctl", "clients", "-j"])])
    .then(([monitors, clients]) => update(findPeeks(JSON.parse(monitors), JSON.parse(clients))))
    .catch(() => update({}))

let pending = 0
const refresh = () => {
  if (pending) return
  pending = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 30, () => {
    pending = 0
    fetchPeeks()
    return GLib.SOURCE_REMOVE
  })
}

hypr.connect("event", refresh)
refresh()

// Column resizes (colresize/fit, mouse drags) send no IPC event, so poll as well; otherwise a
// strip keeps the size its neighbour had before the resize, or never appears for one it uncovers.
// Fast enough that strips reappear promptly once the animation ends.
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => {
  fetchPeeks()
  return GLib.SOURCE_CONTINUE
})

const focus = (address: string) =>
  execAsync(["hyprctl", "dispatch", `hl.dsp.focus({ window = "address:${address}" })`]).catch(console.error)

function PeekStrip(gdkmonitor: Gdk.Monitor, side: Side) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  const [hovered, setHovered] = createState(false)

  const here = peeks((p) => p[gdkmonitor.connector ?? ""]?.[side] ?? null)

  // A cursor warp (moving focus to another monitor/window) never sends the strip a leave
  // event, so it stayed lit with the pointer elsewhere. Drop the hover whenever focus moves or
  // the strip changes neighbour; motion over the strip turns it back on.
  let address = here.peek()?.address
  here.subscribe(() => {
    const next = here.peek()?.address
    if (next !== address) setHovered(false)
    address = next
  })
  hypr.connect("event", (_, event) => {
    if (event === "activewindowv2" || event === "workspacev2" || event === "focusedmonv2") setHovered(false)
  })

  const margin = (f: (p: Peek) => number) => here((p) => (p ? Math.max(Math.round(f(p)), 0) : 0))

  // Anchored to every edge and placed by margins, so Hyprland sizes the surface. Sizing it from
  // the content instead let it grow with a wider neighbour but never shrink back (GTK windows
  // keep their largest size), leaving the strip wider than the column it covers.

  return (
    <window
      visible={here((p) => p !== null)}
      namespace="column-peek"
      cssClasses={["column-peek"]}
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.NONE}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      marginLeft={margin((p) => p.x)}
      marginTop={margin((p) => p.y)}
      marginRight={margin((p) => p.mw - p.x - p.w)}
      marginBottom={margin((p) => p.mh - p.y - p.h)}
      application={app}
    >
      <box cursor={pointer} cssClasses={hovered((h) => (h ? ["strip", side, "hover"] : ["strip", side]))}>
        <Gtk.EventControllerMotion
          onEnter={() => setHovered(true)}
          onMotion={() => setHovered(true)}
          onLeave={() => setHovered(false)}
        />
        <Gtk.GestureClick
          onReleased={() => {
            const p = here.peek()
            setHovered(false)
            if (p) focus(p.address)
          }}
        />
        <label
          cssClasses={["chevron"]}
          // Too narrow a strip would be stretched by the icon, so it only shows when it fits
          visible={here((p) => (p?.w ?? 0) >= 24)}
          hexpand
          halign={Gtk.Align.CENTER}
          label={CHEVRON[side]}
        />
      </box>
    </window>
  )
}

// Clickable strip over each half-visible neighbour column: pointer cursor on hover, click focuses it
export default function ColumnPeek(gdkmonitor: Gdk.Monitor) {
  return [PeekStrip(gdkmonitor, "left"), PeekStrip(gdkmonitor, "right")]
}
