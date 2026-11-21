import { Gtk } from "ags/gtk4"
import { pointer } from "./common"
import { powerOff, reboot } from "./system"

// Pill with an accent bar, icon and label; the accent comes from its class (green reboot, red shutdown)
const Pill = ({ name, icon, label, onClicked }: { name: string; icon: string; label: string; onClicked: () => void }) => (
  <button cssClasses={["pill", name]} cursor={pointer} focusOnClick={false} onClicked={onClicked}>
    <box>
      <label cssClasses={["icon"]} label={icon} />
      <label cssClasses={["caption"]} label={label} />
    </box>
  </button>
)

export default function PowerButtons() {
  return (
    <box cssClasses={["power"]} halign={Gtk.Align.END} valign={Gtk.Align.END}>
      <Pill name="reboot" icon={"\uf01e"} label="REBOOT" onClicked={reboot} />
      <Pill name="shutdown" icon={"\uf011"} label="SHUTDOWN" onClicked={powerOff} />
    </box>
  )
}
