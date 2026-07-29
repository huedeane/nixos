import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createBinding, createComputed } from "ags"
import { MonitorFocusContext } from "../../lib/context"
import app from "ags/gtk4/app"
import style from "./header-bar.scss"
import Hyprland from "gi://AstalHyprland"
import Application from "./application/application"
import Workspace from "./workspace/workspace"
import DateTime from "./datetime/datetime"
import Volume from "./volume/volume"
import Battery from "./battery/battery"

app.apply_css(style)

const hypr = Hyprland.get_default()

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  const focusedMon = createBinding(hypr, "focusedMonitor")
  const focused = createComputed(
    () => focusedMon()?.name === gdkmonitor.connector,
  )

  return (
    <window
      visible
      name="bar"
      class="header-bar-component"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <MonitorFocusContext value={focused}>
        {() => (
          <centerbox
            cssClasses={["header-bar"]}
            hexpand
            halign={Gtk.Align.FILL}
          >
            <box $type="start" halign={Gtk.Align.START} spacing={10}>
              <Application />
              <Workspace gdkmonitor={gdkmonitor} />
            </box>
            <box $type="center" halign={Gtk.Align.CENTER}>
              <DateTime />
            </box>
            <box $type="end" halign={Gtk.Align.END} spacing={10}>
              <Battery />
              <Volume />
              <Application />
            </box>
          </centerbox>
        )}
      </MonitorFocusContext>
    </window>
  )
}
