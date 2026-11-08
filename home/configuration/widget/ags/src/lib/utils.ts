import { Astal, Gdk, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import Graphene from "gi://Graphene"
import GLib from "gi://GLib"
import Hyprland from "gi://AstalHyprland"

export const pointer = Gdk.Cursor.new_from_name("pointer", null)

// Point a bar popover at the middle of the screen instead of its button
export const centerOnScreen = (popover: Gtk.Popover) => {
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

// Open bar popovers, most recently opened last
const openPopovers = new Set<Gtk.Popover>()

// Hyprland's damage tracking misses parts of bar popovers and leaves stale borders behind,
// so it redraws the whole screen only while one of them is open
export const trackFullRedraw = (popover: Gtk.Popover) => {
  const update = () => {
    const mode = openPopovers.size > 0 ? 0 : 2
    execAsync(["hyprctl", "dispatch", `function() hl.config({ debug = { damage_tracking = ${mode} } }) end`]).catch(
      console.error,
    )
  }
  popover.connect("show", () => (openPopovers.add(popover), update()))
  popover.connect("closed", () => (openPopovers.delete(popover), update()))
}

const hyprLua = (code: string) => execAsync(["hyprctl", "dispatch", `function() ${code} end`]).catch(console.error)

// Super+Shift+F (`ags request focus-popup`): park the cursor in the middle of the newest open
// popover, or hand over to Hyprland's focus_topmost_float when none is open
export const focusPopup = () => {
  const popover = [...openPopovers].at(-1)
  const popup = popover?.get_surface() as Gdk.Popup | null | undefined
  const bar = popover?.get_parent()?.get_root() as Astal.Window | null | undefined
  const monitor = bar?.gdkmonitor?.get_geometry()
  if (!popup || !monitor) return hyprLua("focus_topmost_float()"), "float"
  // The popup's position is relative to the bar, which sits at the monitor's top-left
  const x = Math.round(monitor.x + popup.get_position_x() + popup.get_width() / 2)
  const y = Math.round(monitor.y + popup.get_position_y() + popup.get_height() / 2)
  hyprLua(`park_cursor({ x = ${x}, y = ${y} })`)
  return "popup"
}

// Bar popovers close as soon as Hyprland moves focus somewhere else. Otherwise one can lose
// its input grab but stay on screen, ignoring every click and key until it's toggled again
const autoClose = new Map<Gtk.Popover, number>()
// Opening a popover can itself shuffle focus, so ignore events right after it shows
const OPEN_GRACE_MS = 300

export const closeOnFocusLoss = (popover: Gtk.Popover) => {
  popover.connect("show", () => autoClose.set(popover, GLib.get_monotonic_time()))
  popover.connect("closed", () => autoClose.delete(popover))
}

Hyprland.get_default().connect("event", (_, event, data) => {
  if (autoClose.size === 0) return
  const movedFocus =
    (event === "activewindowv2" && data !== "") || event === "workspacev2" || event === "focusedmonv2"
  if (!movedFocus) return
  const now = GLib.get_monotonic_time()
  for (const [popover, shownAt] of autoClose) {
    if ((now - shownAt) / 1000 > OPEN_GRACE_MS) popover.popdown()
  }
})

export const closePopups = () => {
  const count = autoClose.size
  for (const popover of [...autoClose.keys()]) popover.popdown()
  return `${count}`
}

// A closed popover leaves its button stuck in the hover state
export const clearHover = (widget: Gtk.Widget) => {
  widget.unset_state_flags(Gtk.StateFlags.PRELIGHT)
  for (let c = widget.get_first_child(); c; c = c.get_next_sibling()) clearHover(c)
}
