import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"

const ICON_DESKTOP = "\u{f108}"

const read = (path: string) => {
  try {
    return new TextDecoder().decode(GLib.file_get_contents(path)[1])
  } catch {
    return ""
  }
}

// "NixOS 26.11", from os-release's NAME and VERSION_ID
const osVersion = () => {
  const field = (key: string) => read("/etc/os-release").match(new RegExp(`^${key}="?([^"\\n]*)`, "m"))?.[1] ?? ""
  return [field("NAME"), field("VERSION_ID")].filter(Boolean).join(" ")
}

// "up 3d 4h", "up 4h 12m" or "up 12m"
const uptime = () => {
  const minutes = Math.floor(Number(read("/proc/uptime").split(" ")[0]) / 60)
  const [d, h, m] = [Math.floor(minutes / 1440), Math.floor((minutes % 1440) / 60), minutes % 60]
  return `up ${d > 0 ? `${d}d ${h}h` : h > 0 ? `${h}h ${m}m` : `${m}m`}`
}

const Divider = () => <box cssClasses={["divider"]} valign={Gtk.Align.CENTER} />

// Bottom left: hostname, NixOS version and uptime, in a pill like reboot and shutdown
export default function MachineInfo() {
  return (
    <box cssClasses={["pill", "machine"]} halign={Gtk.Align.START} valign={Gtk.Align.END}>
      <label cssClasses={["icon"]} label={ICON_DESKTOP} />
      <label cssClasses={["host"]} label={GLib.get_host_name()} />
      <Divider />
      <label label={osVersion()} />
      <Divider />
      <label cssClasses={["uptime"]} label={createPoll(uptime(), 60_000, uptime)} />
    </box>
  )
}
