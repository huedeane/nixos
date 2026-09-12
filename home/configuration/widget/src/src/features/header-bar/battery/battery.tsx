import { createBinding, createComputed } from "ags"
import { MonitorFocusContext } from "../../../lib/context"
import style from "./battery.scss"
import app from "ags/gtk4/app"
import AstalBattery from "gi://AstalBattery"

app.apply_css(style)

const CHARGING = "󰂄"
const LEVELS = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

export default function Battery() {
  const isFocused = MonitorFocusContext.use()
  const battery = AstalBattery.get_default()

  const percentage = createBinding(battery, "percentage")
  const charging = createBinding(battery, "charging")
  const isPresent = createComputed(
    [createBinding(battery, "isPresent"), createBinding(battery, "deviceType")],
    (present, type) => present && type === AstalBattery.Type.BATTERY,
  )

  const icon = createComputed([percentage, charging], (p, c) => {
    if (c) return CHARGING
    return LEVELS[Math.min(9, Math.max(0, Math.floor(p * 10)))]
  })

  return (
    <box
      visible={isPresent}
      cssClasses={isFocused((f) =>
        f ? ["battery", "component", "focused"] : ["battery", "component"],
      )}
      spacing={10}
    >
      <label label={icon} />
      <label label={percentage((p) => `${Math.round(p * 100)}%`)} />
    </box>
  )
}
