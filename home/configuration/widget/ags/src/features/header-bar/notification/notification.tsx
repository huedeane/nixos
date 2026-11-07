import { createComputed, onCleanup } from "ags"
import type { Accessor } from "ags"
import { Gtk } from "ags/gtk4"
import { MonitorFocusContext } from "../../../lib/context"
import app from "ags/gtk4/app"
import { centerOnScreen, clearHover, closeOnFocusLoss, pointer, trackFullRedraw } from "../../../lib/utils"
import { NotificationPanel, getSource, paint, DIM } from "../../notification-panel/notification-panel"
import type { Source } from "../../notification-panel/notification-panel"
import style from "./notification.scss"

app.apply_css(style)

const ICON_BELL = "\u{f0f3}"
const ICON_BELL_OFF = "\u{f1f6}"

// One notification popover per bar; `ags request notifications` toggles the focused monitor's
const panels: { popover: Gtk.Popover; focused: Accessor<boolean> }[] = []

export const toggleNotifications = () => {
  const panel = panels.find((p) => p.focused.get()) ?? panels[0]
  if (!panel) return "no notification panel"
  if (panel.popover.visible) panel.popover.popdown()
  else panel.popover.popup()
  return "ok"
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
          const entry = { popover: self, focused: isFocused }
          panels.push(entry)
          onCleanup(() => panels.splice(panels.indexOf(entry), 1))
          trackFullRedraw(self)
          closeOnFocusLoss(self)
          self.connect("show", () => {
            centerOnScreen(self)
            self.get_parent()?.add_css_class("open")
          })
          self.connect("closed", () => {
            const button = self.get_parent()
            button?.remove_css_class("open")
            if (button) clearHover(button)
          })
        }}
      >
        <NotificationPanel src={src} />
      </popover>
    </menubutton>
  )
}
