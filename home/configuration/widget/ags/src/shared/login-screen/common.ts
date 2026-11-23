import { Gdk, Gtk } from "ags/gtk4"
import style from "./login-screen.scss"

// Login-screen stylesheets go one step above ags's app.apply_css. At equal priority GTK lets
// whichever stylesheet loaded last win, however specific the rule, so the shell's plain
// `label { color }` (re-emitted by every file that uses style.scss) would recolour these screens
export const applyCss = (css: string) => {
  const provider = new Gtk.CssProvider()
  provider.connect("parsing-error", (_, section, error) =>
    console.error(`CSS Error ${section.get_start_location().lines + 1}: ${error.message}`),
  )
  provider.load_from_string(css)
  Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default()!, provider, Gtk.STYLE_PROVIDER_PRIORITY_USER + 1)
}

// Imported by every shared login-screen component, so their styles load wherever one is used
applyCss(style)

// Kept here rather than in lib/utils, which pulls in Hyprland the greeter doesn't run under
export const pointer = Gdk.Cursor.new_from_name("pointer", null)

// The layout is drawn in 1080p pixels and scaled to the screen (--s in _mixins.scss)
const DESIGN_WIDTH = 1920
const scale = new Gtk.CssProvider()
let scaleAdded = false

export const setScale = (monitor: Gdk.Monitor | null) => {
  if (!monitor) return
  if (!scaleAdded) {
    Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default()!, scale, Gtk.STYLE_PROVIDER_PRIORITY_USER)
    scaleAdded = true
  }
  scale.load_from_string(`window.login-screen { --s: ${monitor.get_geometry().width / DESIGN_WIDTH}; }`)
}
