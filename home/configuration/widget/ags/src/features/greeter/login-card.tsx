import { createComputed, createState } from "ags"
import type { Accessor } from "ags"
import { Gdk, Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import { pointer } from "./common"

// Nerd Font icons
const ICON_EYE = "\uf06e"
const ICON_EYE_OFF = "\uf070"
const ICON_CAPS = "\u{f0632}"
const ICON_RETURN = "\u{f0311}"
const DOT = 0xf111

type Props = {
  user: Accessor<string>
  loggingIn: Accessor<boolean>
  failed: Accessor<boolean>
  onSubmit: (password: string) => void
  onEdit: () => void
  onSwitchUser: () => void
}

export default function LoginCard({ user, loggingIn, failed, onSubmit, onEdit, onSwitchUser }: Props) {
  const [shown, setShown] = createState(false)
  const keyboard = Gdk.Display.get_default()?.get_default_seat()?.get_keyboard()
  const [caps, setCaps] = createState(keyboard?.caps_lock_state ?? false)
  keyboard?.connect("notify::caps-lock-state", () => setCaps(keyboard.caps_lock_state))

  let entry: Gtk.Entry
  let clearing = false
  const submit = () => {
    if (!loggingIn.get()) onSubmit(entry.get_text())
  }

  return (
    <box
      cssClasses={failed((f) => (f ? ["login-card", "failed"] : ["login-card"]))}
      orientation={Gtk.Orientation.VERTICAL}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <box cssClasses={["header"]}>
        <label cssClasses={["title"]} label="Login" hexpand xalign={0} />
        <button cssClasses={["user"]} focusable={false} cursor={pointer} onClicked={onSwitchUser}>
          <label label={user} />
        </button>
      </box>

      <box cssClasses={["password"]}>
        <entry
          cssClasses={shown((s) => (s ? ["shown"] : []))}
          hexpand
          visibility={shown}
          invisibleChar={DOT}
          placeholderText="password"
          editable={loggingIn((l) => !l)}
          onActivate={submit}
          onChanged={() => clearing || onEdit()}
          $={(self) => {
            entry = self
            // Wrong password: start over with an empty field, without that counting as an edit
            // that would hide the error straight away
            failed.subscribe(() => {
              if (!failed.get()) return
              clearing = true
              self.set_text("")
              clearing = false
              self.grab_focus()
            })
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => (self.grab_focus(), GLib.SOURCE_REMOVE))
          }}
        />
        <button
          cssClasses={shown((s) => (s ? ["eye", "active"] : ["eye"]))}
          focusable={false}
          cursor={pointer}
          visible={loggingIn((l) => !l)}
          onClicked={() => (setShown(!shown.get()), entry.grab_focus())}
        >
          <label label={shown((s) => (s ? ICON_EYE_OFF : ICON_EYE))} />
        </button>
        <Gtk.Spinner cssClasses={["spinner"]} spinning visible={loggingIn} />
      </box>

      <box cssClasses={["status"]}>
        <box cssClasses={["caps"]} visible={createComputed(() => caps() && !failed())}>
          <label label={ICON_CAPS} />
          <label label="caps on" />
        </box>
        <label cssClasses={["error"]} label="wrong password, try again" visible={failed} />
        <box hexpand />
        <button cssClasses={["login"]} cursor={pointer} focusOnClick={false} sensitive={loggingIn((l) => !l)} onClicked={submit}>
          <box>
            <label label="Login" />
            <label cssClasses={["key"]} label={ICON_RETURN} valign={Gtk.Align.CENTER} />
          </box>
        </button>
      </box>
    </box>
  )
}
