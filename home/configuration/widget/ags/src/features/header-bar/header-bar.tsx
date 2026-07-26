import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createPoll } from "ags/time"
import style from "./header-bar.scss"
import ApplicationButton from "./application-button/application-button"
import Workspace from "./workspace/workspace"
import DateTime from "./datetime/datetime"

app.apply_css(style)

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const time = createPoll("", 1000, "date")
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

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
      <centerbox cssClasses={["header-bar"]} hexpand halign={Gtk.Align.FILL}>
        <box $type="start" halign={Gtk.Align.START} hexpand={false}>
          <ApplicationButton />
          <Workspace gdkmonitor={gdkmonitor} />
        </box>
        <box $type="center" halign={Gtk.Align.CENTER} hexpand={false}>
          <DateTime />
        </box>
        <box $type="end" halign={Gtk.Align.END} hexpand={false}>
          <ApplicationButton />
        </box>
      </centerbox>
      {/* <centerbox cssName="centerbox"> */}
      {/*   <box $type="center" /> */}
      {/*   <menubutton $type="end" hexpand halign={Gtk.Align.CENTER}> */}
      {/*     <label label={time} /> */}
      {/*     <popover> */}
      {/*       <Gtk.Calendar /> */}
      {/*     </popover> */}
      {/*   </menubutton> */}
      {/* </centerbox> */}
    </window>
  )
}
