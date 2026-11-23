import { Gtk } from "ags/gtk4"
import { pointer } from "./common"

// Pill with an accent bar, icon and label; the accent comes from its class (green reboot, red shutdown)
const Pill = ({ name, icon, label, onClicked }: { name: string; icon: string; label: string; onClicked: () => void }) => (
  <button cssClasses={["pill", name]} cursor={pointer} focusOnClick={false} onClicked={onClicked}>
    <box>
      <label cssClasses={["icon"]} label={icon} />
      <label cssClasses={["caption"]} label={label} />
    </box>
  </button>
)

// The handlers come from each feature: the greeter fakes them outside greetd, the lock screen doesn't
type Props = { onReboot: () => void; onPowerOff: () => void }

export default function PowerButtons({ onReboot, onPowerOff }: Props) {
  return (
    <box cssClasses={["power"]} halign={Gtk.Align.END} valign={Gtk.Align.END}>
      <Pill name="reboot" icon={"\uf01e"} label="REBOOT" onClicked={onReboot} />
      <Pill name="shutdown" icon={"\uf011"} label="SHUTDOWN" onClicked={onPowerOff} />
    </box>
  )
}
