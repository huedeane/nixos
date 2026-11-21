import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"
import { palette } from "../../lib/palette"

// HH:mm with the colon in lavender, and the date in capitals underneath ("dddd, MMMM d")
const time = () => GLib.DateTime.new_now_local().format(`%H<span foreground="${palette.lavender}">:</span>%M`) ?? ""
const date = () => GLib.DateTime.new_now_local().format("%A, %B %-d")?.toUpperCase() ?? ""

export default function Clock() {
  return (
    <box cssClasses={["clock"]} orientation={Gtk.Orientation.VERTICAL} halign={Gtk.Align.CENTER} valign={Gtk.Align.START}>
      <label cssClasses={["time"]} useMarkup label={createPoll(time(), 1000, time)} />
      <label cssClasses={["date"]} label={createPoll(date(), 60_000, date)} />
    </box>
  )
}
