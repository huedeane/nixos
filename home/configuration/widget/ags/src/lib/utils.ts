import { Gdk, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import Graphene from "gi://Graphene"

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

// Hyprland's damage tracking misses parts of bar popovers and leaves stale borders behind,
// so it redraws the whole screen only while one of them is open
let openPopovers = 0
export const trackFullRedraw = (popover: Gtk.Popover) => {
  const update = (step: number) => {
    openPopovers = Math.max(0, openPopovers + step)
    const mode = openPopovers > 0 ? 0 : 2
    execAsync(["hyprctl", "dispatch", `function() hl.config({ debug = { damage_tracking = ${mode} } }) end`]).catch(
      console.error,
    )
  }
  popover.connect("show", () => update(1))
  popover.connect("closed", () => update(-1))
}

// A closed popover leaves its button stuck in the hover state
export const clearHover = (widget: Gtk.Widget) => {
  widget.unset_state_flags(Gtk.StateFlags.PRELIGHT)
  for (let c = widget.get_first_child(); c; c = c.get_next_sibling()) clearHover(c)
}
