import { createComputed, createState, onCleanup } from "ags"
import type { Accessor } from "ags"
import { Gdk, Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import Graphene from "gi://Graphene"
import { pointer } from "./common"

// Nerd Font icons
const ICON_EYE = "\uf06e"
const ICON_EYE_OFF = "\uf070"
const ICON_CAPS = "\u{f0632}"
const ICON_RETURN = "\u{f0311}"
// Plain asterisks for the hidden password
const DOT = 0x2a
// Gap between the last character and the caret, as a share of the line height; GTK draws its
// own caret touching the character, so the field hides it and draws this one instead
const CARET_GAP = 0.2
// Space above and below the caret, each a share of the line height
const CARET_INSET = 0.15
// Raised a little to line up with the asterisks, which sit above the middle of the line
const CARET_RAISE = 2
const CARET_BLINK_MS = 530

type Props = {
  user: Accessor<string>
  loggingIn: Accessor<boolean>
  failed: Accessor<boolean>
  onSubmit: (password: string) => void
  onEdit: () => void
  // Clicking the name cycles users; without it the name is just a label (lock screen)
  onSwitchUser?: () => void
  // Card heading and button text: "Login" for the greeter, "Locked" / "Unlock" for the lock screen
  title?: string
  action?: string
  // Dim line under the field when there's no error or caps warning to show
  note?: Accessor<string>
}

export default function LoginCard({
  user,
  loggingIn,
  failed,
  onSubmit,
  onEdit,
  onSwitchUser,
  title = "Login",
  action = "Login",
  note,
}: Props) {
  const [shown, setShown] = createState(false)
  const keyboard = Gdk.Display.get_default()?.get_default_seat()?.get_keyboard()
  const [caps, setCaps] = createState(keyboard?.caps_lock_state ?? false)
  keyboard?.connect("notify::caps-lock-state", () => setCaps(keyboard.caps_lock_state))

  let entry: Gtk.Entry
  let caret: Gtk.Box
  let field: Gtk.Overlay
  let blink = 0
  onCleanup(() => blink && GLib.source_remove(blink))

  // Moves the caret to just past GTK's (hidden) one and restarts its blink; shown only while the
  // field has focus and nothing is selected. On the next idle, so the text has been laid out
  const placeCaret = () =>
    GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
      const text = entry.get_delegate() as Gtk.Text
      const [strong] = text.compute_cursor_extents(entry.get_position())
      const [ok, at] = text.compute_point(field, new Graphene.Point({ x: strong.get_x(), y: strong.get_y() }))
      const height = strong.get_height()
      const gap = entry.get_position() > 0 ? height * CARET_GAP : 0
      const inset = height * CARET_INSET
      caret.marginStart = Math.round(at.x + gap)
      caret.marginTop = Math.max(0, Math.round(at.y + inset - CARET_RAISE))
      caret.heightRequest = Math.round(height - 2 * inset)
      const [selected] = entry.get_selection_bounds()
      caret.visible = ok && text.has_focus && !selected
      caret.opacity = 1
      if (blink) GLib.source_remove(blink)
      blink = GLib.timeout_add(GLib.PRIORITY_DEFAULT, CARET_BLINK_MS, () => {
        caret.opacity = caret.opacity ? 0 : 1
        return GLib.SOURCE_CONTINUE
      })
      return GLib.SOURCE_REMOVE
    })

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
        <label cssClasses={["title"]} label={title} hexpand xalign={0} />
        <button
          cssClasses={["user"]}
          focusable={false}
          canTarget={!!onSwitchUser}
          cursor={onSwitchUser ? pointer : null}
          onClicked={() => onSwitchUser?.()}
        >
          <label label={user} />
        </button>
      </box>

      <box cssClasses={["password"]}>
        <overlay hexpand $={(self) => (field = self)}>
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
              const text = self.get_delegate() as Gtk.Text
              for (const signal of ["notify::cursor-position", "notify::selection-bound", "notify::visibility", "map"])
                self.connect(signal, placeCaret)
              text.connect("notify::has-focus", placeCaret)
              // Wrong password: start over with an empty field, without that counting as an edit
              // that would hide the error straight away
              failed.subscribe(() => {
                if (!failed.get()) return
                clearing = true
                self.set_text("")
                clearing = false
                self.grab_focus()
              })
              GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => (self.grab_focus(), placeCaret(), GLib.SOURCE_REMOVE))
            }}
          />
          <box
            $type="overlay"
            cssClasses={["caret"]}
            canTarget={false}
            halign={Gtk.Align.START}
            valign={Gtk.Align.START}
            visible={false}
            $={(self) => (caret = self)}
          />
        </overlay>
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
        {note && (
          <label cssClasses={["status-note"]} label={note} visible={createComputed(() => !caps() && !failed())} />
        )}
        <box hexpand />
        <button cssClasses={["login"]} cursor={pointer} focusOnClick={false} sensitive={loggingIn((l) => !l)} onClicked={submit}>
          <box>
            <label label={action} />
            <label cssClasses={["key"]} label={ICON_RETURN} valign={Gtk.Align.CENTER} />
          </box>
        </button>
      </box>
    </box>
  )
}
