import { execAsync } from "ags/process"
import { MonitorFocusContext } from "../../../lib/context"
import app from "ags/gtk4/app"
import style from "./application.scss"

app.apply_css(style)

export default function Application() {
  const isFocused = MonitorFocusContext.use()

  return (
    <button
      cssClasses={isFocused((f) =>
        f
          ? ["application", "component", "focused"]
          : ["application", "component"],
      )}
      onClicked={() => execAsync("echo hello").then(console.log)}
    >
      <label label="" />
    </button>
  )
}
