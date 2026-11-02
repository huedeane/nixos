import { execAsync } from "ags/process"
import { MonitorFocusContext } from "../../../lib/context"
import app from "ags/gtk4/app"
import style from "./application.scss"
import { pointer } from "../../../lib/utils"

app.apply_css(style)

export default function Application() {
  const isFocused = MonitorFocusContext.use()

  return (
    <button
      cursor={pointer}
      cssClasses={isFocused((f) =>
        f
          ? ["application", "component", "focused"]
          : ["application", "component"],
      )}
      onClicked={() => execAsync("rofi -show drun").then(console.log)}
    >
      <label label="" />
    </button>
  )
}
