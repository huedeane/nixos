import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { MonitorFocusContext } from "../../../lib/context"
import app from "ags/gtk4/app"
import style from "./datetime.scss"
import { closeOnFocusLoss, pointer } from "../../../lib/utils"

app.apply_css(style)

export default function DateTime() {
  const time = createPoll("", 1000, "date +'%I:%M:%S %p'")
  const date = createPoll("", 60_000, "date +'%B %d %Y'")
  const isFocused = MonitorFocusContext.use()

  return (
    <menubutton
      cursor={pointer}
      cssClasses={isFocused((f) =>
        f ? ["datetime", "component", "focused"] : ["datetime", "component"],
      )}
    >
      <box spacing={8}>
        <label label={date} />
        <label label={"-"} />
        <label label={time} />
      </box>
      <popover $={closeOnFocusLoss}>
        <Gtk.Calendar />
      </popover>
    </menubutton>
  )
}
