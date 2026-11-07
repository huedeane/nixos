import { onCleanup } from "ags"
import type { Accessor } from "ags"
import { Gtk } from "ags/gtk4"
import { MonitorFocusContext } from "../../../lib/context"
import app from "ags/gtk4/app"
import { centerOnScreen, clearHover, closeOnFocusLoss, pointer, trackFullRedraw } from "../../../lib/utils"
import { LauncherPanel } from "../../launcher-panel/launcher-panel"
import style from "./launcher.scss"

app.apply_css(style)

const ICON_APPS = "\u{f003b}"

// One launcher popover per bar; `ags request launcher` toggles the one on the focused monitor
const launchers: { popover: Gtk.Popover; focused: Accessor<boolean> }[] = []

export const toggleLauncher = () => {
  const launcher = launchers.find((l) => l.focused.get()) ?? launchers[0]
  if (!launcher) return "no launcher"
  if (launcher.popover.visible) launcher.popover.popdown()
  else launcher.popover.popup()
  return "ok"
}

export default function Launcher() {
  const isFocused = MonitorFocusContext.use()

  return (
    <menubutton
      cursor={pointer}
      cssClasses={isFocused((f) => ["launcher", "component", ...(f ? ["focused"] : [])])}
    >
      <label label={ICON_APPS} />
      <popover
        hasArrow={false}
        $={(self) => {
          const entry = { popover: self, focused: isFocused }
          launchers.push(entry)
          onCleanup(() => launchers.splice(launchers.indexOf(entry), 1))
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
        <LauncherPanel />
      </popover>
    </menubutton>
  )
}
