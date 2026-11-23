import { createState, createBinding } from "ags"
import { MonitorFocusContext } from "../../lib/context"
import app from "ags/gtk4/app"
import AstalWp from "gi://AstalWp"
import style from "./microphone.scss"
import { pointer } from "../../lib/utils"

app.apply_css(style)

const audio = AstalWp.get_default()!.audio

const [allMuted, setAllMuted] = createState(false)
const volume = createBinding(audio, "defaultMicrophone", "volume")

function muteAllInputs(state: boolean) {
  for (const m of audio.get_microphones()) m.set_mute(state)
  for (const r of audio.get_recorders()) r.set_mute(state)
  setAllMuted(state)
}

// lockScreen: no spacing of its own, the lock screen spaces the icon
export default function Microphone({ lockScreen = false }: { lockScreen?: boolean } = {}) {
  const isFocused = MonitorFocusContext.use()

  return (
    <button
      cursor={pointer}
      cssClasses={isFocused((f) =>
        f
          ? ["microphone", "component", "focused"]
          : ["microphone", "component"],
      )}
      onClicked={() => muteAllInputs(!allMuted.peek())}
    >
      {/* No spacing on the lock screen, which spaces the icon itself (lock-screen.scss) */}
      <box spacing={lockScreen ? 0 : 10}>
        <label cssClasses={["icon"]} label={allMuted((m) => (m ? "󰍭" : "󰍬"))} />
        <label
          cssClasses={["percentage"]}
          label={volume((v) => `${Math.round(v * 100)}%`)}
        />
      </box>
    </button>
  )
}
