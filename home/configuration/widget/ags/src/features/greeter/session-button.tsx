import { createState } from "ags"
import type { Accessor } from "ags"
import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import { pointer } from "./common"
import type { Session } from "./system"

const ICON_SESSION = "\uf108"
const ICON_CARET = "\uf0d8"

// "Hyprland (uwsm-managed)" -> name and the note shown dimmed after it
const split = (name: string) => {
  const i = name.indexOf(" (")
  return i < 0 ? [name, ""] : [name.slice(0, i), name.slice(i + 1)]
}

const Name = ({ name }: { name: Accessor<string> | string }) => {
  const parts = (typeof name === "string" ? createState(name)[0] : name)(split)
  return (
    <box spacing={8}>
      <label cssClasses={["name"]} label={parts(([n]) => n)} />
      <label cssClasses={["note"]} label={parts(([, note]) => note)} visible={parts(([, note]) => !!note)} />
    </box>
  )
}

type Props = {
  sessions: Session[]
  current: Accessor<Session | undefined>
  onSelect: (session: Session) => void
}

export default function SessionButton({ sessions, current, onSelect }: Props) {
  const [open, setOpen] = createState(false)
  let popover: Gtk.Popover
  const rows = new Map<string, Gtk.Button>()

  return (
    <menubutton
      cssClasses={open((o) => (o ? ["pill", "session", "open"] : ["pill", "session"]))}
      cursor={pointer}
      direction={Gtk.ArrowType.UP}
      halign={Gtk.Align.START}
      valign={Gtk.Align.END}
      // The menubutton's inner button is what takes focus on click
      $={(self) => (self.get_first_child() as Gtk.Widget | null)?.set_focus_on_click(false)}
    >
      <box>
        <label cssClasses={["icon"]} label={ICON_SESSION} />
        <label cssClasses={["caption"]} label="SESSION" />
        <box cssClasses={["divider"]} valign={Gtk.Align.CENTER} />
        <Name name={current((s) => s?.name ?? "Default")} />
        <label cssClasses={["caret"]} label={ICON_CARET} visible={open} />
      </box>
      <popover
        cssClasses={["session-popup"]}
        hasArrow={false}
        // Left edges line up with the pill instead of the list centring over it
        halign={Gtk.Align.START}
        onShow={() => {
          setOpen(true)
          // Once it's on screen; focusing before that has no effect
          GLib.idle_add(GLib.PRIORITY_DEFAULT, () => (rows.get(current.get()?.id ?? "")?.grab_focus(), GLib.SOURCE_REMOVE))
        }}
        onClosed={() => setOpen(false)}
        $={(self) => (popover = self)}
      >
        <box orientation={Gtk.Orientation.VERTICAL}>
          {sessions.map((session) => (
            <button
              cssClasses={current((s) => (s?.id === session.id ? ["row", "current"] : ["row"]))}
              cursor={pointer}
              onClicked={() => (onSelect(session), popover.popdown())}
              $={(self) => rows.set(session.id, self)}
            >
              <Name name={session.name} />
            </button>
          ))}
        </box>
      </popover>
    </menubutton>
  )
}
