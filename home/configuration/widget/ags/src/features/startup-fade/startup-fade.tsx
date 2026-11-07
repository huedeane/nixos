import { Astal, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"
import cairo from "cairo"
import style from "./startup-fade.scss"

app.apply_css(style)

// Hold black briefly so the wallpaper and bar can map underneath, then fade out
const HOLD_MS = 250
const FADE_MS = 3000

// Only fade once per Hyprland session, not on every ags restart
const flag = `${GLib.get_user_runtime_dir()}/ags-startup-fade-${GLib.getenv("HYPRLAND_INSTANCE_SIGNATURE") ?? ""}`
const shouldFade = !GLib.file_test(flag, GLib.FileTest.EXISTS)
if (shouldFade) GLib.file_set_contents(flag, "")

export default function StartupFade(gdkmonitor: Gdk.Monitor) {
  if (!shouldFade) return null
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible
      namespace="startup-fade"
      cssClasses={["startup-fade-window"]}
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.NONE}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      application={app}
      $={(self) => {
        // Let every click pass through to the windows underneath
        self.connect("map", () => self.get_surface()?.set_input_region(new cairo.Region()))
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, HOLD_MS, () => {
          self.add_css_class("faded")
          return GLib.SOURCE_REMOVE
        })
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, HOLD_MS + FADE_MS + 100, () => {
          self.destroy()
          return GLib.SOURCE_REMOVE
        })
      }}
    >
      <box cssClasses={["startup-fade"]} hexpand vexpand />
    </window>
  )
}
