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

let pending = 0
const refresh = () => {
  if (pending) return
  pending = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 30, () => {
    pending = 0
    execAsync(["hyprctl", "activewindow", "-j"])
      .then((out) => {
        const w = JSON.parse(out)
        const monitor = hypr.get_monitor(w.monitor)
        if (!w.address || !monitor || w.fullscreen === 2) return setTarget(null)
        setTarget({
          address: w.address,
          monitor: monitor.name,
          x: w.at[0] + w.size[0] + 1 - monitor.x,
          y: w.at[1] - 2 - monitor.y,
        })
      })
      .catch(() => setTarget(null))
    return GLib.SOURCE_REMOVE
  })
}

hypr.connect("event", refresh)
refresh()

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
