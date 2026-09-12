import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { MonitorFocusContext } from "../../../lib/context"
import app from "ags/gtk4/app"
import style from "./datetime.scss"

app.apply_css(style)

export default function DateTime() {
  const time = createPoll("", 1000, "date +'%I:%M:%S %p'")
  const date = createPoll("", 60_000, "date +'%d %B %Y'")
  const isFocused = MonitorFocusContext.use()

  return (
    <menubutton
      cssClasses={isFocused((f) =>
        f ? ["datetime", "component", "focused"] : ["datetime", "component"],
      )}
    >
      <box spacing={8}>
        <label label={date} />
        <label label={"-"} />
        <label label={time} />
      </box>
      <popover>
        <Gtk.Calendar />
      </popover>
    </menubutton>
  )
}
