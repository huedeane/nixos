import { createBinding, createComputed } from "ags"
import { MonitorFocusContext } from "../../lib/context"
import style from "./volume.scss"
import app from "ags/gtk4/app"
import AstalWp from "gi://AstalWp"
import { pointer } from "../../lib/utils"

app.apply_css(style)

// lockScreen: no spacing of its own, the lock screen spaces the icon
export default function Volume({ lockScreen = false }: { lockScreen?: boolean } = {}) {
  const speaker = AstalWp.get_default()!.defaultSpeaker

  const volume = createBinding(speaker, "volume")
  const muted = createBinding(speaker, "mute")
  const icon = createBinding(speaker, "volumeIcon")
  // Material Design speakers, the same icon set as the mic's, so the two read the same size
  const volumeLabel = createComputed([muted, volume], (m, v) => {
    if (m || v === 0) return "\u{f075f}"
    const p = Math.round(v * 100)
    if (p < 34) return "\u{f057f}"
    if (p < 67) return "\u{f0580}"
    return "\u{f057e}"
  })
  const isFocused = MonitorFocusContext.use()

  return (
    <button
      cursor={pointer}
      cssClasses={isFocused((f) =>
        f ? ["volume", "component", "focused"] : ["volume", "component"],
      )}
      onClicked={() => (speaker.mute = !speaker.mute)}
    >
      {/* No spacing on the lock screen, which spaces the icon itself (lock-screen.scss) */}
      <box spacing={lockScreen ? 0 : 15}>
        <label cssClasses={["icon"]} label={volumeLabel} />
        <label label={volume((v) => `${Math.round(v * 100)}%`)} />
      </box>
    </button>
  )
}
