import { createBinding, createComputed } from "ags"
import { Gtk } from "ags/gtk4"
import { MonitorFocusContext } from "../../../lib/context"
import style from "./volume.scss"
import app from "ags/gtk4/app"
import AstalWp from "gi://AstalWp"

app.apply_css(style)

export default function Volume() {
  const speaker = AstalWp.get_default()!.defaultSpeaker

  const volume = createBinding(speaker, "volume") // 0.0 – 1.0
  const muted = createBinding(speaker, "mute")
  const icon = createBinding(speaker, "volumeIcon") // themed icon name
  const volumeLabel = createComputed([muted, volume], (m, v) => {
    if (m || v === 0) return ""
    const p = Math.round(v * 100)
    if (p < 34) return ""
    if (p < 67) return ""
    return ""
  })
  const isFocused = MonitorFocusContext.use()

  return (
    <button
      cssClasses={isFocused((f) =>
        f ? ["volume", "component", "focused"] : ["volume", "component"],
      )}
      onClicked={() => (speaker.mute = !speaker.mute)}
    >
      <box spacing={15}>
        <label label={volumeLabel} />
        <label label={volume((v) => `${Math.round(v * 100)}%`)} />
      </box>
    </button>
  )
}
