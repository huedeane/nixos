import app from "ags/gtk4/app"
import style from "./datetime.scss"
import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"

app.apply_css(style)

export default function DateTime() {
  const time = createPoll("", 1000, "date +'%I:%M:%S %p'")
  const date = createPoll("", 60_000, "date +'%d %B %Y'")

  return (
    <menubutton cssClasses={["datetime-component"]}>
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
