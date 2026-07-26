import app from "ags/gtk4/app"
import style from "./application-button.scss"
import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"

app.apply_css(style)

export default function ApplicationButton() {
  return (
    <button
      cssClasses={["application-button-component"]}
      onClicked={() => execAsync("echo hello").then(console.log)}
      hexpand
      halign={Gtk.Align.CENTER}
    >
      <label label="" />
    </button>
  )
}
