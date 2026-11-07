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
type Peek = { address: string; x: number; y: number; w: number; h: number }
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
      const box = { address: c.address, y: c.at[1] - BORDER - m.y, h: c.size[1] + BORDER * 2 }
      if (x0 < left && x1 > left) sides.left = { ...box, x: 0, w: x1 - left }
      if (x0 < right && x1 > right) sides.right = { ...box, x: x0 - left, w: right - x0 }
    }
  }
  return result
}

let pending = 0
const refresh = () => {
  if (pending) return
  pending = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 30, () => {
    pending = 0
    Promise.all([execAsync(["hyprctl", "monitors", "-j"]), execAsync(["hyprctl", "clients", "-j"])])
      .then(([monitors, clients]) => setPeeks(findPeeks(JSON.parse(monitors), JSON.parse(clients))))
      .catch(() => setPeeks({}))
    return GLib.SOURCE_REMOVE
  })
}

hypr.connect("event", refresh)
refresh()

const focus = (address: string) =>
  execAsync(["hyprctl", "dispatch", `hl.dsp.focus({ window = "address:${address}" })`]).catch(console.error)

function PeekStrip(gdkmonitor: Gdk.Monitor, side: Side) {
  const { TOP, LEFT } = Astal.WindowAnchor
  const [hovered, setHovered] = createState(false)

  const here = peeks((p) => p[gdkmonitor.connector ?? ""]?.[side] ?? null)

  return (
    <window
      visible={here((p) => p !== null)}
      namespace="column-peek"
      cssClasses={["column-peek"]}
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.NONE}
      anchor={TOP | LEFT}
      marginLeft={here((p) => Math.max(p?.x ?? 0, 0))}
      marginTop={here((p) => Math.max(p?.y ?? 0, 0))}
      application={app}
    >
      <box
        cursor={pointer}
        cssClasses={hovered((h) => (h ? ["strip", side, "hover"] : ["strip", side]))}
        widthRequest={here((p) => Math.max(Math.round(p?.w ?? 1), 1))}
        heightRequest={here((p) => Math.max(Math.round(p?.h ?? 1), 1))}
      >
        <Gtk.EventControllerMotion onEnter={() => setHovered(true)} onLeave={() => setHovered(false)} />
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
