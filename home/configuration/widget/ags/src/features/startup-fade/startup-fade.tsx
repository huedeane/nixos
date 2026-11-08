import { Astal, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"
import { execAsync } from "ags/process"
import cairo from "cairo"
import style from "./startup-fade.scss"

app.apply_css(style)

// Hold black briefly so the wallpaper and bar can map underneath, then fade out
const HOLD_MS = 250
const FADE_MS = 3000
const WALLPAPER_TIMEOUT_MS = 5000

const sleep = (ms: number) =>
  new Promise<void>((resolve) =>
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, ms, () => {
      resolve()
      return GLib.SOURCE_REMOVE
    }),
  )

const waitForWallpaper = async () => {
  const deadline = Date.now() + WALLPAPER_TIMEOUT_MS
  while (Date.now() < deadline) {
    const active = await execAsync("hyprctl hyprpaper listactive").catch(() => "")
    if (active.includes("/")) return
    await sleep(50)
  }
}

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
        const onMap = async () => {
          // Let every click pass through to the windows underneath
          self.get_surface()?.set_input_region(new cairo.Region())
          await execAsync("systemctl --user start hyprpaper.service").catch(console.error)
          await waitForWallpaper()
          await sleep(HOLD_MS)
          self.add_css_class("faded")
          await sleep(FADE_MS + 100)
          execAsync(["hyprctl", "eval", "show_startup_cursor()"]).catch(console.error)
          self.destroy()
        }
        if (self.get_mapped()) onMap()
        else self.connect("map", onMap)
      }}
    >
      <box cssClasses={["startup-fade"]} hexpand vexpand />
    </window>
  )
}
