import { createComputed, onCleanup } from "ags"
import type { Accessor } from "ags"
import { Gtk } from "ags/gtk4"
import { MonitorFocusContext } from "../../lib/context"
import app from "ags/gtk4/app"
import { centerOnScreen, clearHover, closeOnFocusLoss, pointer, trackFullRedraw } from "../../lib/utils"
import { NotificationPanel, getSource, paint, DIM } from "../../features/notification-panel/notification-panel"
import type { Source } from "../../features/notification-panel/notification-panel"
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

// lockScreen: "2 notifications" (or "0 notifications") next to the bell, and no panel, so a
// locked screen can't be used to read them; the bar shows just the bell and opens the panel.
// count: what the number shows, dunst's history by default (the lock screen counts since locking)
export default function Notification({
  src = getSource(),
  lockScreen = false,
  count = src.total,
}: { src?: Source; lockScreen?: boolean; count?: Accessor<number> } = {}) {
  const isFocused = MonitorFocusContext.use()

  return (
    <menubutton
      // Without a panel there's nothing to click or tab to: no pointer cursor, hover or focus
      cursor={lockScreen ? null : pointer}
      canTarget={!lockScreen}
      canFocus={!lockScreen}
      cssClasses={createComputed(() => [
        "notification",
        "component",
        ...(isFocused() ? ["focused"] : []),
        ...(src.dnd() ? ["dnd"] : []),
        ...(lockScreen ? ["has-count"] : []),
      ])}
    >
      {/* No spacing on the lock screen, which spaces the icon itself (lock-screen.scss). Centred,
          since the button's min-width is wider than the bell and a box packs it to the start */}
      <box spacing={lockScreen ? 0 : 8} halign={Gtk.Align.CENTER}>
        <label
          cssClasses={["icon"]}
          useMarkup
          label={src.dnd((d) => (d ? paint(ICON_BELL_OFF, DIM) : ICON_BELL))}
        />
        {/* How many the panel lists (dunst's history), "0 notifications" included */}
        <label
          cssClasses={["count"]}
          label={count((t) => `${t} notification${t === 1 ? "" : "s"}`)}
          visible={lockScreen}
        />
      </box>
      {!lockScreen && (
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
      )}
    </menubutton>
  )
}
