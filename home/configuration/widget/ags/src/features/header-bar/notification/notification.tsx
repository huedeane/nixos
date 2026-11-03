import { createComputed } from "ags"
import { Gdk, Gtk } from "ags/gtk4"
import Graphene from "gi://Graphene"
import { MonitorFocusContext } from "../../../lib/context"
import app from "ags/gtk4/app"
import { pointer } from "../../../lib/utils"
import { NotificationPanel, getSource, paint, DIM } from "../../notification-panel/notification-panel"
import type { Source } from "../../notification-panel/notification-panel"
import style from "./notification.scss"

app.apply_css(style)

const ICON_BELL = "\u{f0f3}"
const ICON_BELL_OFF = "\u{f1f6}"

const centerOnScreen = (popover: Gtk.Popover) => {
  const button = popover.get_parent()
  const root = button?.get_root() as Gtk.Widget | null
  if (!button || !root) return
  const [ok, point] = button.compute_point(root, new Graphene.Point({ x: 0, y: 0 }))
  if (!ok) return
  popover.set_pointing_to(
    new Gdk.Rectangle({
      x: Math.round(root.get_width() / 2 - point.x),
      y: 0,
      width: 1,
      height: button.get_height(),
    }),
  )
}

const clearHover = (widget: Gtk.Widget) => {
  widget.unset_state_flags(Gtk.StateFlags.PRELIGHT)
  for (let c = widget.get_first_child(); c; c = c.get_next_sibling()) clearHover(c)
}

export default function Notification({ src = getSource() }: { src?: Source } = {}) {
  const isFocused = MonitorFocusContext.use()

  return (
    <menubutton
      cursor={pointer}
      cssClasses={createComputed(() => [
        "notification",
        "component",
        ...(isFocused() ? ["focused"] : []),
        ...(src.dnd() ? ["dnd"] : []),
      ])}
    >
      <label useMarkup label={src.dnd((d) => (d ? paint(ICON_BELL_OFF, DIM) : ICON_BELL))} />
      <popover
        hasArrow={false}
        $={(self) => {
          self.connect("show", () => centerOnScreen(self))
          self.connect("closed", () => {
            const button = self.get_parent()
            if (button) clearHover(button)
          })
        }}
      >
        <NotificationPanel src={src} />
      </popover>
    </menubutton>
  )
}
